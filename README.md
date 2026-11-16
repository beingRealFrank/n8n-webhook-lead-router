# n8n-webhook-lead-router

An [n8n](https://n8n.io) workflow that receives a lead on a webhook, validates and normalises it, and forwards good leads to a target URL.

`POST /webhook/lead` with JSON `{name, email, phone, source}`:
1. **Validate + normalise** (Code node): trims names, lowercases email, reduces phone to 10 digits, lowercases source.
2. **Valid?** (IF): needs a name and a well-formed email.
3. Valid → **Forward to target** (HTTP Request to the `TARGET_URL` environment variable) → **200** with the normalised lead.
   Invalid → **400** with an error message.

Import `workflow.json` in n8n (Workflows → Import from file) and set `TARGET_URL`. No credentials are stored in the file.

## Test
```
bash test.sh
```
This is a **structure and code test**: it checks the workflow's wiring (webhook path, both IF branches, 200/400 responses) and unit-tests the Code node's JavaScript (`code_node.js`, which must match the node embedded in `workflow.json`) with plain Node. It does not start n8n, so it is not an end-to-end test.

MIT licensed.
