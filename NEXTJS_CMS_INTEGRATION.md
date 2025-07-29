# Implementasi di Aplikasi Next.js CMS

## Setup Aplikasi Next.js CMS

### 1. Install Dependencies

```bash
npm install @supabase/supabase-js
# atau
yarn add @supabase/supabase-js
```

### 2. Konfigurasi Supabase

```javascript
// lib/supabase.js
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
```

### 3. Environment Variables

```env
# .env.local
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
NEXT_PUBLIC_FLUTTER_APP_URL=https://your-flutter-app.web.app
```

### 4. Auth Hook

```javascript
// hooks/useAuth.js
import { useEffect, useState } from "react";
import { supabase } from "../lib/supabase";

export function useAuth() {
	const [user, setUser] = useState(null);
	const [loading, setLoading] = useState(true);

	useEffect(() => {
		// Get initial session
		supabase.auth.getSession().then(({ data: { session } }) => {
			setUser(session?.user ?? null);
			setLoading(false);
		});

		// Listen for auth changes
		const {
			data: { subscription },
		} = supabase.auth.onAuthStateChange((_event, session) => {
			setUser(session?.user ?? null);
			setLoading(false);
		});

		return () => subscription.unsubscribe();
	}, []);

	return { user, loading };
}
```

### 5. Dashboard Component

```javascript
// pages/dashboard.js
import { useAuth } from "../hooks/useAuth";
import { supabase } from "../lib/supabase";

export default function Dashboard() {
	const { user, loading } = useAuth();

	const openCashier = async () => {
		try {
			// Get current session
			const {
				data: { session },
			} = await supabase.auth.getSession();

			if (!session) {
				alert("Anda harus login terlebih dahulu");
				return;
			}

			// Generate expiry (24 jam dari sekarang)
			const expiry = new Date(Date.now() + 24 * 60 * 60 * 1000);

			// Generate Flutter URL dengan token
			const flutterUrl = `${process.env.NEXT_PUBLIC_FLUTTER_APP_URL}/?token=${
				session.access_token
			}&expiry=${expiry.toISOString()}`;

			// Buka di tab baru
			window.open(flutterUrl, "_blank");
		} catch (error) {
			console.error("Error opening cashier:", error);
			alert("Terjadi kesalahan saat membuka kasir");
		}
	};

	if (loading) {
		return <div>Loading...</div>;
	}

	if (!user) {
		return <div>Anda harus login terlebih dahulu</div>;
	}

	return (
		<div className="dashboard">
			<h1>Dashboard CMS</h1>
			<p>Selamat datang, {user.email}</p>

			<div className="actions">
				<button onClick={openCashier} className="btn btn-primary">
					Buka Kasir
				</button>

				<button
					onClick={() => supabase.auth.signOut()}
					className="btn btn-secondary">
					Logout
				</button>
			</div>
		</div>
	);
}
```

### 6. Login Component

```javascript
// pages/login.js
import { useState } from "react";
import { useRouter } from "next/router";
import { supabase } from "../lib/supabase";

export default function Login() {
	const [email, setEmail] = useState("");
	const [password, setPassword] = useState("");
	const [loading, setLoading] = useState(false);
	const router = useRouter();

	const handleLogin = async (e) => {
		e.preventDefault();
		setLoading(true);

		try {
			const { error } = await supabase.auth.signInWithPassword({
				email,
				password,
			});

			if (error) {
				alert(error.message);
			} else {
				router.push("/dashboard");
			}
		} catch (error) {
			alert("Terjadi kesalahan saat login");
		} finally {
			setLoading(false);
		}
	};

	return (
		<div className="login">
			<h1>Login CMS</h1>

			<form onSubmit={handleLogin}>
				<div>
					<label>Email:</label>
					<input
						type="email"
						value={email}
						onChange={(e) => setEmail(e.target.value)}
						required
					/>
				</div>

				<div>
					<label>Password:</label>
					<input
						type="password"
						value={password}
						onChange={(e) => setPassword(e.target.value)}
						required
					/>
				</div>

				<button type="submit" disabled={loading}>
					{loading ? "Loading..." : "Login"}
				</button>
			</form>
		</div>
	);
}
```

### 7. Auth Guard Component

```javascript
// components/AuthGuard.js
import { useAuth } from "../hooks/useAuth";
import { useRouter } from "next/router";
import { useEffect } from "react";

export default function AuthGuard({ children }) {
	const { user, loading } = useAuth();
	const router = useRouter();

	useEffect(() => {
		if (!loading && !user) {
			router.push("/login");
		}
	}, [user, loading, router]);

	if (loading) {
		return <div>Loading...</div>;
	}

	if (!user) {
		return null;
	}

	return children;
}
```

### 8. Layout dengan Auth Guard

```javascript
// pages/_app.js
import AuthGuard from "../components/AuthGuard";
import "../styles/globals.css";

export default function App({ Component, pageProps }) {
	return (
		<AuthGuard>
			<Component {...pageProps} />
		</AuthGuard>
	);
}
```

### 9. Styling (CSS)

```css
/* styles/globals.css */
.dashboard {
	padding: 2rem;
	max-width: 1200px;
	margin: 0 auto;
}

.actions {
	margin-top: 2rem;
	display: flex;
	gap: 1rem;
}

.btn {
	padding: 0.75rem 1.5rem;
	border: none;
	border-radius: 0.5rem;
	cursor: pointer;
	font-size: 1rem;
}

.btn-primary {
	background-color: #007bff;
	color: white;
}

.btn-secondary {
	background-color: #6c757d;
	color: white;
}

.btn:hover {
	opacity: 0.9;
}

.login {
	max-width: 400px;
	margin: 4rem auto;
	padding: 2rem;
	border: 1px solid #ddd;
	border-radius: 0.5rem;
}

.login form {
	display: flex;
	flex-direction: column;
	gap: 1rem;
}

.login input {
	padding: 0.5rem;
	border: 1px solid #ddd;
	border-radius: 0.25rem;
}
```

## Testing

### 1. Test Local Development

```bash
# Start Next.js app
npm run dev

# Buka http://localhost:3000
# Login dengan credentials yang valid
# Klik "Buka Kasir" button
# Verifikasi bahwa Flutter app terbuka dengan token
```

### 2. Test Production

```bash
# Build dan deploy
npm run build
npm run start

# Atau deploy ke Vercel/Netlify
```

## Security Considerations

### 1. Token Expiry

- Token memiliki expiry time (24 jam)
- Token expired otomatis invalid
- User harus login ulang jika token expired

### 2. HTTPS

- Pastikan semua komunikasi menggunakan HTTPS
- Jangan gunakan HTTP untuk production

### 3. Environment Variables

- Jangan expose sensitive data di client-side
- Gunakan environment variables untuk konfigurasi

### 4. Error Handling

- Handle semua error dengan graceful
- Berikan feedback yang jelas ke user

## Troubleshooting

### 1. Token tidak terkirim

- Cek Supabase session
- Pastikan user sudah login
- Cek console untuk error

### 2. Flutter app tidak terbuka

- Cek URL Flutter app
- Pastikan URL accessible
- Cek browser popup blocker

### 3. Auto login tidak berfungsi

- Cek token format di URL
- Pastikan token tidak expired
- Cek Flutter app console untuk error

## Best Practices

1. **User Experience**: Berikan loading state saat membuka kasir
2. **Error Handling**: Handle semua kemungkinan error
3. **Security**: Validasi token di server-side jika perlu
4. **Monitoring**: Log semua aktivitas untuk debugging
5. **Testing**: Test di berbagai browser dan device
