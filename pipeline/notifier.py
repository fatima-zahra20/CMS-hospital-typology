# pipeline/notifier.py
import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime
from pathlib import Path

from pipeline.logger import get_logger

log = get_logger(__name__)


def load_env():
    """Read .env file from project root into os.environ."""
    env_file = Path(__file__).resolve().parent.parent / ".env"
    if not env_file.exists():
        return
    for line in env_file.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, val = line.split("=", 1)
            os.environ[key.strip()] = val.strip()


def send_failure(step: str, error: str) -> None:
    """Send a failure email when the pipeline halts."""
    load_env()
    sender   = os.environ.get("GMAIL_SENDER")
    password = os.environ.get("GMAIL_PASSWORD")
    receiver = os.environ.get("GMAIL_RECEIVER")

    if not all([sender, password, receiver]):
        log.warning("notifier: .env missing — skipping email notification")
        return

    subject = f" CMS Pipeline FAILED — {step} — {datetime.now().strftime('%Y-%m-%d')}"
    body    = f"""
CMS Hospital Typology Pipeline - FAILURE REPORT
================================================
Time:  {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Step:  {step}
Error: {error}

Check the log file for full traceback:
logs/pipeline_{datetime.now().strftime('%Y-%m-%d')}.log
"""
    msg = MIMEMultipart()
    msg["From"]    = sender
    msg["To"]      = receiver
    msg["Subject"] = subject
    msg.attach(MIMEText(body, "plain"))

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(sender, password)
            server.sendmail(sender, receiver, msg.as_string())
        log.info(f"notifier: failure email sent to {receiver}")
    except Exception as e:
        log.error(f"notifier: failed to send email — {e}")


def send_success() -> None:
    """Send a success email when the pipeline completes."""
    load_env()
    sender   = os.environ.get("GMAIL_SENDER")
    password = os.environ.get("GMAIL_PASSWORD")
    receiver = os.environ.get("GMAIL_RECEIVER")

    if not all([sender, password, receiver]):
        return

    subject = f" CMS Pipeline SUCCESS — {datetime.now().strftime('%Y-%m-%d')}"
    body    = f"""
CMS Hospital Typology Pipeline — SUCCESS
=========================================
Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

All steps passed. Fresh CSVs are ready in agg_output/csv_output/.
"""
    msg = MIMEMultipart()
    msg["From"]    = sender
    msg["To"]      = receiver
    msg["Subject"] = subject
    msg.attach(MIMEText(body, "plain"))

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(sender, password)
            server.sendmail(sender, receiver, msg.as_string())
        log.info(f"notifier: success email sent to {receiver}")
    except Exception as e:
        log.error(f"notifier: failed to send email — {e}")