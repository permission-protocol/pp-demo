import re

file_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/scripts/test-atomic-loop.ts'
with open(file_path, 'r') as f:
    content = f.read()

# Fix the executeCall reporting logic
old_exec = """    if (expectedToFail) {
      console.log(`${testName}: ${!result.allowed ? '✅ DENY' : '❌ ALLOW'} - ${result.reason}`);
    } else {
      console.log(`${testName}: ${result.allowed ? '✅ ALLOW' : '❌ DENY - ' + result.reason}`);"""

new_exec = """    if (expectedToFail) {
      console.log(`${testName}: ${!result.allowed ? '✅ DENY' : '❌ ALLOW'} - ${result.reason || 'No reason provided'}`);
    } else {
      console.log(`${testName}: ${result.allowed ? '✅ ALLOW' : '❌ DENY - ' + (result.reason || '')}`);"""

content = content.replace(old_exec, new_exec)

with open(file_path, 'w') as f:
    f.write(content)
