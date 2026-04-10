const STRIPE_KEY = process.env.STRIPE_SECRET_KEY;

export async function charge(customerId: string, amount: number) {
  const stripe = require('stripe')(STRIPE_KEY);
  return stripe.charges.create({ customer: customerId, amount });
}
