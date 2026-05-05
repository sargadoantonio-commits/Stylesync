import { registerWithUsernameSecure, signInWithUsernameSecure, syncServerPasswordCredential } from '../src/auth_secure';
import { initializeTestApp } from 'firebase-functions-test';

const testEnv = initializeTestApp({
  projectId: 'test-project',
  secrets: {
    STYLESYNC_PEPPER: 'test-pepper-at-least-16-chars-long',
  },
});

// Mock dependencies
jest.mock('firebase-admin', () => ({
  getAuth: jest.fn(() => ({
    createUser: jest.fn(),
    createCustomToken: jest.fn(),
    deleteUser: jest.fn(),
  })),
  getFirestore: jest.fn(() => ({
    collection: jest.fn().mockReturnThis(),
    doc: jest.fn().mockReturnThis(),
    batch: jest.fn(() => ({
      set: jest.fn(),
      commit: jest.fn(),
    })),
    runTransaction: jest.fn(),
  })),
  FieldValue: {
    serverTimestamp: jest.fn(),
    increment: jest.fn(),
    delete: jest.fn(),
  },
  Timestamp: {
    now: jest.fn(() => ({ seconds: Date.now() / 1000 })),
  },
}));

jest.mock('bcrypt', () => ({
  hash: jest.fn(),
  compare: jest.fn(),
}));

jest.mock('crypto', () => ({
  createHash: jest.fn(() => ({
    update: jest.fn().mockReturnThis(),
    digest: jest.fn().mockReturnValue('mocked-hash'),
  })),
  randomBytes: jest.fn(() => Buffer.from('mocked-random-bytes')),
}));

describe('Auth Functions', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('registerWithUsernameSecure', () => {
    it('should register a new user successfully', async () => {
      const mockAuth = require('firebase-admin').getAuth();
      const mockDb = require('firebase-admin').getFirestore();
      const mockBatch = mockDb.batch();

      mockAuth.createUser.mockResolvedValue({ uid: 'test-uid' });
      mockAuth.createCustomToken.mockResolvedValue('custom-token');
      mockBatch.commit.mockResolvedValue();

      const wrapped = testEnv.wrap(registerWithUsernameSecure);
      const result = await wrapped({
        data: {
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
          role: 'customer',
          isPremium: false,
        },
      });

      expect(result).toEqual({ customToken: 'custom-token' });
      expect(mockAuth.createUser).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
        emailVerified: false,
        disabled: false,
      });
    });

    it('should reject invalid username', async () => {
      const wrapped = testEnv.wrap(registerWithUsernameSecure);

      await expect(wrapped({
        data: {
          username: 'us',
          email: 'test@example.com',
          password: 'password123',
        },
      })).rejects.toThrow('Invalid username');
    });

    it('should reject taken username', async () => {
      const mockDb = require('firebase-admin').getFirestore();
      mockDb.doc().get.mockResolvedValue({ exists: true });

      const wrapped = testEnv.wrap(registerWithUsernameSecure);

      await expect(wrapped({
        data: {
          username: 'takenuser',
          email: 'test@example.com',
          password: 'password123',
        },
      })).rejects.toThrow('Username already taken');
    });
  });

  describe('signInWithUsernameSecure', () => {
    it('should sign in user successfully', async () => {
      const mockAuth = require('firebase-admin').getAuth();
      const mockDb = require('firebase-admin').getFirestore();

      mockDb.doc().get
        .mockResolvedValueOnce({ exists: true, data: () => ({ uid: 'test-uid', email: 'test@example.com' }) })
        .mockResolvedValueOnce({ exists: true, data: () => ({ credentialSalt: 'salt', passwordDigest: '$2a$...' }) });

      const bcrypt = require('bcrypt');
      bcrypt.compare.mockResolvedValue(true);

      mockAuth.createCustomToken.mockResolvedValue('custom-token');

      const wrapped = testEnv.wrap(signInWithUsernameSecure);
      const result = await wrapped({
        data: {
          username: 'testuser',
          password: 'password123',
        },
      });

      expect(result).toEqual({ customToken: 'custom-token' });
    });

    it('should reject invalid credentials', async () => {
      const mockDb = require('firebase-admin').getFirestore();
      mockDb.doc().get.mockResolvedValue({ exists: false });

      const wrapped = testEnv.wrap(signInWithUsernameSecure);

      await expect(wrapped({
        data: {
          username: 'nonexistent',
          password: 'wrongpass',
        },
      })).rejects.toThrow('Invalid Username or Password');
    });
  });

  describe('syncServerPasswordCredential', () => {
    it('should sync password credential for authenticated user', async () => {
      const mockDb = require('firebase-admin').getFirestore();
      const mockDoc = mockDb.doc();
      mockDoc.set.mockResolvedValue();

      const wrapped = testEnv.wrap(syncServerPasswordCredential);
      const result = await wrapped({
        data: { password: 'newpassword123' },
        auth: { uid: 'test-uid' },
      });

      expect(result).toEqual({ ok: true });
      expect(mockDoc.set).toHaveBeenCalled();
    });

    it('should reject unauthenticated requests', async () => {
      const wrapped = testEnv.wrap(syncServerPasswordCredential);

      await expect(wrapped({
        data: { password: 'password123' },
      })).rejects.toThrow('Sign in required');
    });
  });
});