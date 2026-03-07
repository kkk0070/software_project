import { knex } from '../../config/database.js';
import { createPostResponse } from '../../utils/responseHelper.js';

// Get user's wallet balance
export const getWalletBalance = async (req, res) => {
    try {
        const userId = req.user.id;
        let wallet = await knex('wallets').where('user_id', userId).first();

        if (!wallet) {
            // Create wallet if it doesn't exist
            [wallet] = await knex('wallets').insert({
                user_id: userId,
                balance: 0.00,
                currency: 'USD'
            }).returning('*');
        }

        res.json({
            success: true,
            data: wallet
        });
    } catch (error) {
        console.error('Error fetching wallet balance:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching wallet balance',
            error: error.message
        });
    }
};

// Add funds to wallet (Mocked Payment)
export const addFunds = async (req, res) => {
    try {
        const userId = req.user.id;
        const { amount, payment_method_id } = req.body;

        if (!amount || amount <= 0) {
            return res.status(400).json({ success: false, message: 'Invalid amount' });
        }

        // Wrap in a transaction
        await knex.transaction(async (trx) => {
            // 1. "Charge" the mocked card (Pretend it always succeeds)
            // 2. Add to wallet balance
            const [wallet] = await trx('wallets')
                .where('user_id', userId)
                .increment('balance', amount)
                .returning('*');

            if (!wallet) {
                throw new Error('Wallet not found');
            }

            // 3. Record transaction
            await trx('transactions').insert({
                user_id: userId,
                amount: amount,
                type: 'Credit',
                status: 'Completed',
                description: `Added funds via payment method ${payment_method_id || 'Cash'}`
            });

            res.json(createPostResponse({
                success: true,
                message: 'Funds added successfully',
                data: wallet,
                requestBody: req.body
            }));
        });
    } catch (error) {
        console.error('Error adding funds:', error);
        res.status(500).json(createPostResponse({
            success: false,
            message: 'Error processing mock payment',
            data: { error: error.message },
            requestBody: req.body
        }));
    }
};

// Add a mocked payment method
export const addPaymentMethod = async (req, res) => {
    try {
        const userId = req.user.id;
        const { cardToken, last4, brand } = req.body;

        const [method] = await knex('payment_methods').insert({
            user_id: userId,
            provider_method_id: `mock_pm_${Date.now()}`,
            last4: last4 || '4242',
            brand: brand || 'Visa',
            is_default: true
        }).returning('*');

        res.json(createPostResponse({
            success: true,
            message: 'Payment method added',
            data: method,
            requestBody: req.body
        }));
    } catch (error) {
        console.error('Error adding payment method:', error);
        res.status(500).json(createPostResponse({
            success: false,
            message: 'Error adding payment method',
            data: { error: error.message },
            requestBody: req.body
        }));
    }
};

// Get payment methods
export const getPaymentMethods = async (req, res) => {
    try {
        const userId = req.user.id;
        const methods = await knex('payment_methods').where('user_id', userId);

        res.json({
            success: true,
            data: methods
        });
    } catch (error) {
        console.error('Error fetching payment methods:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching payment methods',
            error: error.message
        });
    }
};
