import json
import os
import sys
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../frontend')))

import app as dashboard_app


class TestIoTFullStack(unittest.TestCase):
    def setUp(self):
        self.client = dashboard_app.app.test_client()

    def test_dashboard_index_route(self):
        """Verify the web dashboard HTML renders with HTTP 200."""
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'AWS IoT Core Wireless Telemetry Dashboard', response.data)

    def test_telemetry_api_route_structure(self):
        """Verify /api/telemetry returns expected JSON schema."""
        response = self.client.get('/api/telemetry')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data.decode('utf-8'))
        self.assertIn('status', data)
        self.assertIn('latest', data)
        self.assertIn('history', data)
        self.assertIn('connected', data['status'])

    def test_mqtt_message_ingestion(self):
        """Verify incoming MQTT payload is parsed and added to dashboard history."""
        sample_payload = {
            "deviceId": "MyDemoDevice",
            "temperature": 26.45,
            "humidity": 58.12,
            "ts": "2026-11-17T10:00:00Z"
        }
        class DummyMsg:
            payload = json.dumps(sample_payload).encode('utf-8')

        dashboard_app.on_message(None, None, DummyMsg())
        self.assertEqual(dashboard_app.history[-1]["deviceId"], "MyDemoDevice")
        self.assertEqual(dashboard_app.history[-1]["temperature"], 26.45)
        self.assertEqual(dashboard_app.history[-1]["humidity"], 58.12)


if __name__ == '__main__':
    unittest.main()
