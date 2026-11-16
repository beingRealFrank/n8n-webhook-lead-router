// Body of the "Validate + normalise" Code node (runs once per item in n8n).
// Kept in its own file so it can be unit-tested with plain node.
function normalise(body) {
  const email = String(body.email || '').trim().toLowerCase();
  const name = String(body.name || '').trim().replace(/\s+/g, ' ');
  const phoneDigits = String(body.phone || '').replace(/\D/g, '');
  const phone = phoneDigits.length === 10 ? phoneDigits : (phoneDigits.length === 11 && phoneDigits[0] === '1' ? phoneDigits.slice(1) : '');
  const source = String(body.source || 'unknown').trim().toLowerCase();
  const valid = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email) && name.length > 0;
  return { valid, lead: { name, email, phone, source } };
}
if (typeof module !== 'undefined') module.exports = { normalise };
