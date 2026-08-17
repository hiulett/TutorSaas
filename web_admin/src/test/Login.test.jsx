import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import Login from '../pages/Login';

const mockSignIn = vi.fn();
const mockChallenge = vi.fn();
const mockVerify = vi.fn();

vi.mock('../lib/supabaseClient', () => ({
  supabase: {
    auth: {
      signInWithPassword: (...args) => mockSignIn(...args),
      mfa: {
        challenge: (...args) => mockChallenge(...args),
        verify: (...args) => mockVerify(...args),
      },
    },
  },
}));

describe('Login', () => {
  beforeEach(() => {
    mockSignIn.mockReset();
    mockChallenge.mockReset();
    mockVerify.mockReset();
  });

  it('no permite registro público (solo inicio de sesión)', () => {
    render(<Login onLogin={() => {}} />);
    expect(screen.queryByText('Registrarse')).not.toBeInTheDocument();
    expect(screen.queryByText('Crear Cuenta')).not.toBeInTheDocument();
  });

  it('inicia sesión con email y contraseña y delega la sesión', async () => {
    const onLogin = vi.fn();
    const session = { user: { email: 'admin@tutorsaas.com' } };
    mockSignIn.mockResolvedValue({ data: { session }, error: null });

    const { container } = render(<Login onLogin={onLogin} />);
    fireEvent.change(screen.getByPlaceholderText('admin@tutorsaas.com'), {
      target: { value: 'admin@tutorsaas.com' },
    });
    fireEvent.change(screen.getByPlaceholderText('••••••••'), {
      target: { value: 'secret' },
    });
    fireEvent.submit(container.querySelector('form'));

    await waitFor(() => expect(onLogin).toHaveBeenCalledWith(session));
    expect(mockSignIn).toHaveBeenCalledWith({
      email: 'admin@tutorsaas.com',
      password: 'secret',
    });
  });

  it('muestra el error si la autenticación falla', async () => {
    const onLogin = vi.fn();
    mockSignIn.mockResolvedValue({ data: { session: null }, error: { message: 'Invalid credentials' } });

    const { container } = render(<Login onLogin={onLogin} />);
    fireEvent.change(screen.getByPlaceholderText('admin@tutorsaas.com'), {
      target: { value: 'x@y.z' },
    });
    fireEvent.change(screen.getByPlaceholderText('••••••••'), {
      target: { value: 'wrong' },
    });
    fireEvent.submit(container.querySelector('form'));

    await waitFor(() => expect(screen.getByText('Invalid credentials')).toBeInTheDocument());
    expect(onLogin).not.toHaveBeenCalled();
  });

  it('pide el código TOTP si la cuenta tiene 2FA y delega la sesión tras verificar', async () => {
    const onLogin = vi.fn();
    const session = { user: { email: 'admin@tutorsaas.com' } };
    mockSignIn.mockResolvedValue({ data: { factor_id: 'factor1', session: null }, error: null });
    mockChallenge.mockResolvedValue({ data: { id: 'ch1' }, error: null });
    mockVerify.mockResolvedValue({ data: { valid: true, session }, error: null });

    const { container } = render(<Login onLogin={onLogin} />);
    fireEvent.change(screen.getByPlaceholderText('admin@tutorsaas.com'), {
      target: { value: 'admin@tutorsaas.com' },
    });
    fireEvent.change(screen.getByPlaceholderText('••••••••'), {
      target: { value: 'secret' },
    });
    fireEvent.submit(container.querySelector('form'));

    // Debe aparecer la vista 2FA y pedir el código.
    await waitFor(() => expect(screen.getByPlaceholderText('••••••')).toBeInTheDocument());
    expect(mockSignIn).toHaveBeenCalled();

    fireEvent.change(screen.getByPlaceholderText('••••••'), {
      target: { value: '123456' },
    });
    fireEvent.submit(container.querySelector('form'));

    await waitFor(() => expect(mockChallenge).toHaveBeenCalledWith({ factorId: 'factor1' }));
    expect(mockVerify).toHaveBeenCalledWith({
      factorId: 'factor1',
      challengeId: 'ch1',
      code: '123456',
    });
    await waitFor(() => expect(onLogin).toHaveBeenCalledWith(session));
  });
});
