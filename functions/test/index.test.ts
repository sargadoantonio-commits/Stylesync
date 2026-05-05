import * as admin from 'firebase-admin';
import { onPaymentConfirmed } from '../src/index';
import { initializeTestApp, assertFails, assertSucceeds } from 'firebase-functions-test';

const testEnv = initializeTestApp({
  projectId: 'test-project',
});

// Mock Firestore
const mockFirestore = {
  runTransaction: jest.fn(),
  collection: jest.fn().mockReturnThis(),
  doc: jest.fn().mockReturnThis(),
};

jest.mock('firebase-admin', () => ({
  initializeApp: jest.fn(),
  getFirestore: jest.fn(() => mockFirestore),
}));

describe('onPaymentConfirmed', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should update user XP and loyalty rank on payment confirmation', async () => {
    const beforeData = { paymentConfirmedAt: null };
    const afterData = {
      customerId: 'customer123',
      barberId: 'barber456',
      amount: 500,
      paymentConfirmedAt: admin.firestore.Timestamp.now(),
    };

    const mockTx = {
      get: jest.fn(),
      update: jest.fn(),
      set: jest.fn(),
    };

    mockFirestore.runTransaction.mockImplementation(async (fn) => fn(mockTx));

    mockTx.get.mockResolvedValueOnce({
      exists: true,
      get: jest.fn((field) => (field === 'xp' ? 1000 : undefined)),
    });

    mockTx.get.mockResolvedValueOnce({
      exists: false,
    });

    const wrapped = testEnv.wrap(onPaymentConfirmed);
    const result = await wrapped({
      data: {
        before: { data: () => beforeData },
        after: { data: () => afterData },
      },
    });

    expect(mockTx.update).toHaveBeenCalledWith(
      expect.any(Object),
      expect.objectContaining({
        xp: 1050, // 1000 + 50 (500/10)
        loyaltyRank: 'regular',
      })
    );
    expect(mockTx.set).toHaveBeenCalledWith(
      expect.any(Object),
      expect.objectContaining({
        visitCount: 1,
      })
    );
  });

  it('should not trigger if payment was already confirmed', async () => {
    const beforeData = { paymentConfirmedAt: admin.firestore.Timestamp.now() };
    const afterData = { paymentConfirmedAt: admin.firestore.Timestamp.now() };

    const wrapped = testEnv.wrap(onPaymentConfirmed);
    await wrapped({
      data: {
        before: { data: () => beforeData },
        after: { data: () => afterData },
      },
    });

    expect(mockFirestore.runTransaction).not.toHaveBeenCalled();
  });

  it('should handle invalid data gracefully', async () => {
    const beforeData = { paymentConfirmedAt: null };
    const afterData = {
      customerId: '',
      barberId: '',
      amount: 0,
      paymentConfirmedAt: admin.firestore.Timestamp.now(),
    };

    const wrapped = testEnv.wrap(onPaymentConfirmed);
    await wrapped({
      data: {
        before: { data: () => beforeData },
        after: { data: () => afterData },
      },
    });

    expect(mockFirestore.runTransaction).not.toHaveBeenCalled();
  });
});