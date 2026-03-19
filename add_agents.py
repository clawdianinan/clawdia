#!/usr/bin/env python3
import json
import subprocess
import time

TOKEN = "xoxp-10752295117408-10721969604214-10720956806053-2d89834682ea00843afbce63f78d73a1"

# Agent user IDs
AGENTS = {
    "trinity": "U0ALV2DSETH",
    "fela": "U0AMPCW6NU9",
    "shuri": "U0AMPCTAG1X",
    "ebun": "U0AM444RY75",
    "nova": "U0AMPCUUT33",
    "sheba": "U0AME3HL9LL"
}

print("🚀 Adding agents to Slack channels...")

# Get channel IDs
def get_channel_id(channel_name):
    cmd = [
        "curl", "-s", "-X", "GET",
        f"https://slack.com/api/conversations.list?types=public_channel&limit=100",
        "-H", f"Authorization: Bearer {TOKEN}"
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        data = json.loads(result.stdout)
        if data.get("ok"):
            for channel in data.get("channels", []):
                if channel.get("name") == channel_name:
                    return channel.get("id")
    return None

# Get all channel IDs
channels = {
    "prdforge-launch": get_channel_id("prdforge-launch"),
    "phase1-stabilization": get_channel_id("phase1-stabilization"),
    "phase2-qa-uat": get_channel_id("phase2-qa-uat"),
    "phase3-commercial": get_channel_id("phase3-commercial"),
    "phase4-gtm": get_channel_id("phase4-gtm"),
    "agent-coordination": get_channel_id("agent-coordination"),
    "decisions": get_channel_id("decisions"),
    "blockers": get_channel_id("blockers")
}

print("📋 Channel IDs:")
for name, cid in channels.items():
    if cid:
        print(f"  #{name}: {cid}")

# Add user to channel
def add_to_channel(channel_id, user_id, channel_name, user_name):
    if not channel_id or not user_id:
        return False
    
    print(f"Adding {user_name} to #{channel_name}...")
    
    data = {
        "channel": channel_id,
        "users": [user_id]
    }
    
    cmd = [
        "curl", "-s", "-X", "POST",
        "https://slack.com/api/conversations.invite",
        "-H", f"Authorization: Bearer {TOKEN}",
        "-H", "Content-Type: application/json",
        "-d", json.dumps(data)
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        data = json.loads(result.stdout)
        if data.get("ok"):
            print(f"  ✅ Added")
            return True
        else:
            error = data.get("error", "Unknown")
            print(f"  ⚠️  {error}")
            return False
    return False

# Add all agents to common channels
print("\n📋 Adding to common channels...")
common_channels = ["agent-coordination", "decisions", "blockers", "prdforge-launch"]

for agent_name, user_id in AGENTS.items():
    print(f"\nProcessing {agent_name.capitalize()}...")
    
    for channel_name in common_channels:
        channel_id = channels.get(channel_name)
        if channel_id:
            add_to_channel(channel_id, user_id, channel_name, agent_name.capitalize())
            time.sleep(0.5)

# Add to phase-specific channels
print("\n🎯 Adding to phase-specific channels...")

# Trinity to phase1
if channels.get("phase1-stabilization") and AGENTS.get("trinity"):
    add_to_channel(
        channels["phase1-stabilization"],
        AGENTS["trinity"],
        "phase1-stabilization",
        "Trinity"
    )

# Shuri to phase2
if channels.get("phase2-qa-uat") and AGENTS.get("shuri"):
    add_to_channel(
        channels["phase2-qa-uat"],
        AGENTS["shuri"],
        "phase2-qa-uat",
        "Shuri"
    )

# Sheba to phase3
if channels.get("phase3-commercial") and AGENTS.get("sheba"):
    add_to_channel(
        channels["phase3-commercial"],
        AGENTS["sheba"],
        "phase3-commercial",
        "Sheba"
    )

# Fela, Ebun, Nova to phase4
if channels.get("phase4-gtm"):
    phase4_users = []
    phase4_names = []
    
    for agent in ["fela", "ebun", "nova"]:
        if AGENTS.get(agent):
            phase4_users.append(AGENTS[agent])
            phase4_names.append(agent.capitalize())
    
    if phase4_users:
        print(f"Adding {', '.join(phase4_names)} to #phase4-gtm...")
        
        data = {
            "channel": channels["phase4-gtm"],
            "users": phase4_users
        }
        
        cmd = [
            "curl", "-s", "-X", "POST",
            "https://slack.com/api/conversations.invite",
            "-H", f"Authorization: Bearer {TOKEN}",
            "-H", "Content-Type: application/json",
            "-d", json.dumps(data)
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            data = json.loads(result.stdout)
            if data.get("ok"):
                print(f"  ✅ Added")
            else:
                error = data.get("error", "Unknown")
                print(f"  ⚠️  {error}")

print("\n🎉 Agent channel assignment complete!")