import pytest
import json
import hmac
import hashlib
from unittest.mock import patch, MagicMock
from app import app, make_github_links


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def create_signature(payload_bytes, secret):
    signature = hmac.new(secret.encode(), payload_bytes, hashlib.sha256).hexdigest()
    return f"sha256={signature}"


class TestMakeGithubLinks:
    def test_make_github_links_returns_all_keys(self):
        links = make_github_links("testuser")
        assert "merged_prs" in links
        assert "open_prs" in links
        assert "closed_prs" in links
        assert "issues" in links
        assert "assigned" in links

    def test_make_github_links_contains_username(self):
        links = make_github_links("myuser")
        assert "myuser" in links["merged_prs"]
        assert "myuser" in links["issues"]


class TestHealthEndpoint:
    def test_health_returns_200(self, client):
        response = client.get("/health")
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data["status"] == "healthy"


class TestWebhookEndpoint:
    def test_webhook_ping_returns_200(self, client):
        response = client.post("/webhook", data=b"", headers={"X-GitHub-Event": "ping"})
        assert response.status_code == 200

    def test_webhook_empty_payload_returns_200(self, client):
        response = client.post(
            "/webhook", data=b"", headers={"X-GitHub-Event": "pull_request"}
        )
        assert response.status_code == 200

    def test_webhook_invalid_signature_returns_401(self, client):
        payload = json.dumps({"action": "opened"}).encode()
        response = client.post(
            "/webhook",
            data=payload,
            headers={
                "X-GitHub-Event": "pull_request",
                "X-Hub-Signature-256": "sha256=invalid",
            },
        )
        assert response.status_code == 401

    def test_webhook_valid_signature_accepts_request(self, client):
        payload = json.dumps(
            {
                "action": "opened",
                "pull_request": {"number": 1, "user": {"login": "test"}},
            }
        ).encode()
        signature = create_signature(payload, "test-secret-123")

        with patch("app.verify_webhook_signature", return_value=True):
            with patch("app.handle_pull_request") as mock_handle:
                response = client.post(
                    "/webhook",
                    data=payload,
                    headers={
                        "X-GitHub-Event": "pull_request",
                        "X-Hub-Signature-256": signature,
                        "Content-Type": "application/json",
                    },
                )
                mock_handle.assert_called_once()


class TestWebhookPayloadParsing:
    def test_parse_json_payload(self, client):
        payload = json.dumps({"action": "opened"}).encode()
        signature = create_signature(payload, "test-secret-123")

        with patch("app.verify_webhook_signature", return_value=True):
            with patch("app.handle_pull_request"):
                response = client.post(
                    "/webhook",
                    data=payload,
                    headers={
                        "X-GitHub-Event": "pull_request",
                        "X-Hub-Signature-256": signature,
                        "Content-Type": "application/json",
                    },
                )
                assert response.status_code == 200

    def test_parse_form_encoded_payload(self, client):
        payload_str = f"payload={json.dumps({'action': 'opened'})}"
        payload = payload_str.encode()
        signature = create_signature(payload, "test-secret-123")

        with patch("app.verify_webhook_signature", return_value=True):
            with patch("app.handle_pull_request"):
                response = client.post(
                    "/webhook",
                    data=payload,
                    headers={
                        "X-GitHub-Event": "pull_request",
                        "X-Hub-Signature-256": signature,
                        "Content-Type": "application/x-www-form-urlencoded",
                    },
                )
                assert response.status_code == 200
