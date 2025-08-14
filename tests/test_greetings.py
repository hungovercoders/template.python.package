"""Tests for the greetings module."""

import sys
from unittest.mock import MagicMock, patch

from hungovercoders_template_python_package.greetings import (
    goodbye,
    goodbye_cli,
    hello,
    hello_cli,
)


class TestGreetingFunctions:
    """Test class for greeting functions."""

    def test_hello_returns_correct_message(self) -> None:
        """Test that hello function returns the correct greeting message."""
        result = hello("Alice")
        assert result == "Hungovercoders say hello to Alice!"

    def test_hello_with_world(self) -> None:
        """Test hello function with World."""
        result = hello("World")
        assert result == "Hungovercoders say hello to World!"

    def test_goodbye_returns_correct_message(self) -> None:
        """Test that goodbye function returns the correct farewell message."""
        result = goodbye("Bob")
        assert result == "Hungovercoders say goodbye to Bob!"

    def test_goodbye_with_world(self) -> None:
        """Test goodbye function with World."""
        result = goodbye("World")
        assert result == "Hungovercoders say goodbye to World!"

    @patch("hungovercoders_template_python_package.greetings.logger")
    def test_hello_logs_appropriately(self, mock_logger: MagicMock) -> None:
        """Test that hello function logs the greeting generation."""
        hello("Charlie")
        mock_logger.info.assert_called_once_with("Generated greeting for Charlie")

    @patch("hungovercoders_template_python_package.greetings.logger")
    def test_goodbye_logs_appropriately(self, mock_logger: MagicMock) -> None:
        """Test that goodbye function logs the farewell generation."""
        goodbye("Dave")
        mock_logger.info.assert_called_once_with("Generated farewell for Dave")


class TestCLIFunctions:
    """Test class for CLI functions."""

    def test_hello_cli_default(self, monkeypatch, capsys):
        """Test hello_cli with default argument (no --name)."""
        test_args = ["prog"]
        monkeypatch.setattr(sys, "argv", test_args)
        hello_cli()
        captured = capsys.readouterr()
        assert "Hungovercoders say hello to World!" in captured.out

    def test_hello_cli_with_name(self, monkeypatch, capsys):
        """Test hello_cli with --name argument."""
        test_args = ["prog", "--name", "Bob"]
        monkeypatch.setattr(sys, "argv", test_args)
        hello_cli()
        captured = capsys.readouterr()
        assert "Hungovercoders say hello to Bob!" in captured.out

    def test_goodbye_cli_default(self, monkeypatch, capsys):
        """Test goodbye_cli with default argument (no --name)."""
        test_args = ["prog"]
        monkeypatch.setattr(sys, "argv", test_args)
        goodbye_cli()
        captured = capsys.readouterr()
        assert "Hungovercoders say goodbye to World!" in captured.out

    def test_goodbye_cli_with_name(self, monkeypatch, capsys):
        """Test goodbye_cli with --name argument."""
        test_args = ["prog", "--name", "Dana"]
        monkeypatch.setattr(sys, "argv", test_args)
        goodbye_cli()
        captured = capsys.readouterr()
        assert "Hungovercoders say goodbye to Dana!" in captured.out
