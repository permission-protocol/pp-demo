import re
file_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/lib/authorization/policy.ts'
with open(file_path, 'r') as f:
    content = f.read()

new_content = content.replace("export interface PPConfig {\n  tools: Record<string, ToolPolicy>;\n}", "export interface PPConfig {\n  tools: Record<string, ToolPolicy>;\n  policy_hash?: string;\n}")

if "crypto" not in new_content:
    new_content = "import crypto from 'crypto';\n" + new_content

hash_logic = """  const parsed = yaml.load(fileContents) as PPConfig;
  cachedConfig = parsed || { tools: {} };
  
  // Ensure tools object exists
  if (!cachedConfig.tools) {
    cachedConfig.tools = {};
  }
  cachedConfig.policy_hash = crypto.createHash('sha256').update(fileContents).digest('hex').substring(0, 12);"""

new_content = new_content.replace("""  const parsed = yaml.load(fileContents) as PPConfig;
  cachedConfig = parsed || { tools: {} };
  
  // Ensure tools object exists
  if (!cachedConfig.tools) {
    cachedConfig.tools = {};
  }""", hash_logic)

with open(file_path, 'w') as f:
    f.write(new_content)
