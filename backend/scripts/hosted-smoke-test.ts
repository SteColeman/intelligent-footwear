import process from 'node:process';

type UserProfile = {
  id: string;
  authProviderId: string;
};

type FootwearItem = {
  id: string;
  status: string;
  isDefaultFallback: boolean;
};

const baseURL = process.env.BACKEND_BASE_URL?.trim();

if (!baseURL) {
  console.error('Missing BACKEND_BASE_URL');
  process.exit(1);
}

const demoAuthProviderId = 'demo-user';

async function request(path: string, init?: RequestInit) {
  const response = await fetch(`${baseURL}${path}`, init);
  const text = await response.text();
  let body: unknown = text;

  try {
    body = text ? JSON.parse(text) : null;
  } catch {
    // keep raw text
  }

  if (!response.ok) {
    throw new Error(`Request failed ${response.status} ${response.statusText} for ${path}: ${typeof body === 'string' ? body : JSON.stringify(body)}`);
  }

  return body;
}

async function main() {
  console.log(`Running hosted smoke test against ${baseURL}`);

  const health = await request('/health');
  console.log('✓ /health', health);

  await request('/dev/bootstrap-demo-user', { method: 'POST' });
  console.log('✓ bootstrap demo user');

  const me = await request(`/me?authProviderId=${encodeURIComponent(demoAuthProviderId)}`) as UserProfile;
  console.log('✓ /me', me.id);

  await request('/me/onboarding-complete', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ userId: me.id }),
  });
  console.log('✓ onboarding persisted');

  const created = await request('/footwear', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      userId: me.id,
      brand: 'New Balance',
      model: '990v6',
      nickname: 'Hosted Smoke Pair',
      category: 'trainers',
      isDefaultFallback: true,
    }),
  }) as FootwearItem;
  console.log('✓ create footwear', created.id);

  const updated = await request(`/footwear/${created.id}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      userId: me.id,
      brand: 'New Balance',
      model: '990v6',
      nickname: 'Hosted Retired Pair',
      category: 'trainers',
      isDefaultFallback: true,
      status: 'retired',
    }),
  }) as FootwearItem;

  if (updated.status !== 'retired') {
    throw new Error(`Expected retired status, got ${updated.status}`);
  }

  if (updated.isDefaultFallback !== false) {
    throw new Error('Expected inactive pair to lose default fallback');
  }

  console.log('✓ inactive pair loses default fallback');

  await request(`/footwear/${created.id}/photo`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      userId: me.id,
      photoUrl: 'https://example.com/test-photo.jpg',
    }),
  });
  console.log('✓ update photo');

  const home = await request(`/home-summary?userId=${encodeURIComponent(me.id)}`);
  console.log('✓ home summary', typeof home === 'string' ? home : 'ok');

  const insights = await request(`/insights?userId=${encodeURIComponent(me.id)}`);
  console.log('✓ insights', typeof insights === 'string' ? insights : 'ok');

  console.log('Hosted smoke test completed successfully');
}

main().catch(error => {
  console.error('Hosted smoke test failed');
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
