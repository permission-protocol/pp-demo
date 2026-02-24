#!/usr/bin/env python3
"""
Guest post outreach emails via Postmark SMTP or direct API
"""
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import json
from datetime import datetime

# Email configuration
FROM_EMAIL = "cgoldber82@gmail.com"
FROM_NAME = "Charles Goldberg"

# Outreach targets
EMAILS = [
    {
        "to": "hello@dateyourspouse.com",
        "site_name": "Date Your Spouse",
        "subject": "Guest post collaboration idea for Date Your Spouse?",
        "body": """Hi there!

I came across Date Your Spouse while researching couples activities and was genuinely impressed by your "Sexy Dates" and "Group Dates" categories - the mission of "strengthening marriages one date at a time" really resonates.

I'm Charles from Xdares, where we create engaging party games and dare challenges for couples. I'd love to contribute a guest post that would genuinely help your readers.

Some content ideas that might fit well:

• "10 Dare Games to Spice Up Date Night" - fun, playful challenges for couples
• "Group Date Games That Actually Work" - icebreakers and party games for couples' gatherings  
• "Valentine's Day Dare Challenge for Couples" - seasonal content with romantic dares

I create well-researched, actionable content with original game ideas (not just rehashed lists). Happy to match your editorial style and include your links/calls-to-action.

Would you be interested in exploring this collaboration?

Best regards,
Charles Goldberg
Xdares - Party Games for Adults
https://xdares.com""",
    },
    {
        "to": "info@openlove101.com",
        "site_name": "Open Love 101",
        "subject": "Article submission idea for OpenLove101?",
        "body": """Hi John and Jackie,

I've been following OpenLove101 and love how openly you discuss relationship dynamics that most sites shy away from. Your content on navigating the lifestyle with communication and trust is genuinely helpful.

I'm Charles from Xdares, where we create adult party games and dare challenges. I saw you accept article submissions and wanted to pitch a few ideas that might resonate with your audience:

• "Party Games for Lifestyle Events" - icebreakers and games designed for open-minded gatherings
• "Couples' Dare Challenges That Build Trust" - communication-focused games for partners exploring together
• "Group Games for Adult Parties" - tasteful but spicy entertainment for grown-up gatherings

Our content is designed for adults who want to add playfulness and connection to their relationships - which seems perfectly aligned with your community.

Would you be interested in considering an article submission?

Best regards,
Charles Goldberg
Xdares - Party Games for Adults
https://xdares.com""",
    }
]

def save_drafts():
    """Save email drafts to file for review/manual sending"""
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    drafts_path = f"goals/xdares-seo-growth/outreach/guest-post-drafts-{timestamp}.md"
    
    with open(drafts_path, "w") as f:
        f.write("# Guest Post Outreach Drafts\n\n")
        f.write(f"Generated: {datetime.now().isoformat()}\n\n")
        f.write("---\n\n")
        
        for email in EMAILS:
            f.write(f"## To: {email['site_name']}\n\n")
            f.write(f"**Email:** {email['to']}\n\n")
            f.write(f"**Subject:** {email['subject']}\n\n")
            f.write("**Body:**\n\n")
            f.write(f"```\n{email['body']}\n```\n\n")
            f.write("---\n\n")
    
    print(f"Drafts saved to: {drafts_path}")
    return drafts_path

def send_via_smtp(server, port, username, password, use_tls=True):
    """Send emails via SMTP"""
    results = []
    
    try:
        if use_tls:
            smtp = smtplib.SMTP(server, port)
            smtp.starttls()
        else:
            smtp = smtplib.SMTP_SSL(server, port)
        
        smtp.login(username, password)
        
        for email_data in EMAILS:
            msg = MIMEMultipart()
            msg['From'] = f"{FROM_NAME} <{FROM_EMAIL}>"
            msg['To'] = email_data['to']
            msg['Subject'] = email_data['subject']
            msg.attach(MIMEText(email_data['body'], 'plain'))
            
            try:
                smtp.sendmail(FROM_EMAIL, email_data['to'], msg.as_string())
                results.append({"to": email_data['to'], "status": "sent"})
                print(f"✓ Sent to {email_data['site_name']} ({email_data['to']})")
            except Exception as e:
                results.append({"to": email_data['to'], "status": "failed", "error": str(e)})
                print(f"✗ Failed to send to {email_data['to']}: {e}")
        
        smtp.quit()
    except Exception as e:
        print(f"SMTP connection error: {e}")
        return None
    
    return results

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "--draft":
        # Just save drafts
        save_drafts()
    else:
        print("Usage:")
        print("  python send_outreach.py --draft    # Save drafts to file")
        print("")
        print("To send, use browser automation for Gmail or get Postmark API token")
        save_drafts()
