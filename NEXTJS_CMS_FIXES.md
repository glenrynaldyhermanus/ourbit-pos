# 🔧 Next.js CMS Fixes

## 🚨 Masalah yang Perlu Diperbaiki

### 1. **URL Generation Issue**

URL yang di-generate tidak boleh memiliki hash fragment `#/login`

### 2. **Token Expiry Management**

Perlu memastikan expiry time yang valid

### 3. **Error Handling**

Perlu handling untuk kasus token invalid atau expired

## ✅ Perbaikan yang Diperlukan

### 1. **Fix URL Generation**

#### ❌ **Kode yang Salah:**

```javascript
// pages/dashboard.js
const openCashier = async () => {
	const {
		data: { session },
	} = await supabase.auth.getSession();
	const expiry = new Date(Date.now() + 24 * 60 * 60 * 1000);

	// ❌ SALAH - ada hash fragment yang menyebabkan masalah routing
	const flutterUrl = `https://ourbit-cashier.web.app/?token=${
		session.access_token
	}&expiry=${expiry.toISOString()}#/login`;
	window.open(flutterUrl, "_blank");
};
```

#### ✅ **Kode yang Benar:**

```javascript
// pages/dashboard.js
const openCashier = async () => {
	try {
		const {
			data: { session },
		} = await supabase.auth.getSession();

		if (!session) {
			alert("Anda harus login terlebih dahulu");
			return;
		}

		// ✅ BENAR - tanpa hash fragment
		const expiry = new Date(Date.now() + 24 * 60 * 60 * 1000);
		const flutterUrl = `https://ourbit-cashier.web.app/?token=${
			session.access_token
		}&expiry=${expiry.toISOString()}`;

		console.log("Opening Flutter app with URL:", flutterUrl);
		window.open(flutterUrl, "_blank");
	} catch (error) {
		console.error("Error opening cashier:", error);
		alert("Terjadi kesalahan saat membuka kasir");
	}
};
```

### 2. **Enhanced Token Management**

#### ✅ **Improved Token Service:**

```javascript
// utils/tokenService.js
export class TokenService {
	static generateFlutterUrl(session) {
		if (!session?.access_token) {
			throw new Error("No valid session found");
		}

		// Generate expiry (24 hours from now)
		const expiry = new Date(Date.now() + 24 * 60 * 60 * 1000);

		// Validate token format
		if (!session.access_token.startsWith("eyJ")) {
			throw new Error("Invalid token format");
		}

		const flutterUrl = `https://ourbit-cashier.web.app/?token=${
			session.access_token
		}&expiry=${expiry.toISOString()}`;

		console.log("Generated Flutter URL:", flutterUrl);
		return flutterUrl;
	}

	static validateToken(token) {
		try {
			// Basic JWT format validation
			const parts = token.split(".");
			if (parts.length !== 3) {
				return false;
			}

			// Decode payload to check expiry
			const payload = JSON.parse(atob(parts[1]));
			const now = Math.floor(Date.now() / 1000);

			if (payload.exp && payload.exp < now) {
				return false;
			}

			return true;
		} catch (error) {
			console.error("Token validation error:", error);
			return false;
		}
	}
}
```

### 3. **Updated Dashboard Component**

#### ✅ **Improved Dashboard:**

```javascript
// pages/dashboard.js
import { useAuth } from "../hooks/useAuth";
import { TokenService } from "../utils/tokenService";

export default function Dashboard() {
	const { user, loading } = useAuth();

	const openCashier = async () => {
		try {
			// Get current session
			const {
				data: { session },
				error,
			} = await supabase.auth.getSession();

			if (error) {
				console.error("Session error:", error);
				alert("Error getting session");
				return;
			}

			if (!session) {
				alert("Anda harus login terlebih dahulu");
				return;
			}

			// Validate token before generating URL
			if (!TokenService.validateToken(session.access_token)) {
				alert("Token tidak valid, silakan login ulang");
				await supabase.auth.signOut();
				return;
			}

			// Generate Flutter URL
			const flutterUrl = TokenService.generateFlutterUrl(session);

			// Open Flutter app
			const newWindow = window.open(flutterUrl, "_blank");

			if (!newWindow) {
				alert("Pop-up diblokir. Silakan izinkan pop-up untuk situs ini.");
			}
		} catch (error) {
			console.error("Error opening cashier:", error);
			alert("Terjadi kesalahan saat membuka kasir");
		}
	};

	const handleLogout = async () => {
		try {
			await supabase.auth.signOut();
			// Redirect to login page
			window.location.href = "/login";
		} catch (error) {
			console.error("Logout error:", error);
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

				<button onClick={handleLogout} className="btn btn-secondary">
					Logout
				</button>
			</div>
		</div>
	);
}
```

### 4. **Environment Variables**

#### ✅ **Update .env.local:**

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Flutter App URL
NEXT_PUBLIC_FLUTTER_APP_URL=https://ourbit-cashier.web.app

# Token Configuration
NEXT_PUBLIC_TOKEN_EXPIRY_HOURS=24
```

### 5. **Enhanced Auth Hook**

#### ✅ **Improved useAuth Hook:**

```javascript
// hooks/useAuth.js
import { useEffect, useState } from "react";
import { supabase } from "../lib/supabase";

export function useAuth() {
	const [user, setUser] = useState(null);
	const [loading, setLoading] = useState(true);
	const [session, setSession] = useState(null);

	useEffect(() => {
		// Get initial session
		supabase.auth.getSession().then(({ data: { session }, error }) => {
			if (error) {
				console.error("Session error:", error);
			} else {
				setSession(session);
				setUser(session?.user ?? null);
			}
			setLoading(false);
		});

		// Listen for auth changes
		const {
			data: { subscription },
		} = supabase.auth.onAuthStateChange((_event, session) => {
			setSession(session);
			setUser(session?.user ?? null);
			setLoading(false);
		});

		return () => subscription.unsubscribe();
	}, []);

	return { user, loading, session };
}
```

### 6. **Error Handling Component**

#### ✅ **Error Boundary:**

```javascript
// components/ErrorBoundary.js
import React from "react";

class ErrorBoundary extends React.Component {
	constructor(props) {
		super(props);
		this.state = { hasError: false };
	}

	static getDerivedStateFromError(error) {
		return { hasError: true };
	}

	componentDidCatch(error, errorInfo) {
		console.error("Error caught by boundary:", error, errorInfo);
	}

	render() {
		if (this.state.hasError) {
			return (
				<div className="error-boundary">
					<h2>Terjadi kesalahan</h2>
					<p>Silakan refresh halaman atau hubungi administrator.</p>
					<button onClick={() => window.location.reload()}>
						Refresh Halaman
					</button>
				</div>
			);
		}

		return this.props.children;
	}
}

export default ErrorBoundary;
```

### 7. **Loading States**

#### ✅ **Loading Component:**

```javascript
// components/LoadingSpinner.js
export default function LoadingSpinner({ message = "Loading..." }) {
	return (
		<div className="loading-spinner">
			<div className="spinner"></div>
			<p>{message}</p>
		</div>
	);
}
```

### 8. **Updated CSS**

#### ✅ **Enhanced Styling:**

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
	transition: all 0.2s ease;
}

.btn-primary {
	background-color: #007bff;
	color: white;
}

.btn-primary:hover {
	background-color: #0056b3;
}

.btn-secondary {
	background-color: #6c757d;
	color: white;
}

.btn-secondary:hover {
	background-color: #545b62;
}

.loading-spinner {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	height: 200px;
}

.spinner {
	width: 40px;
	height: 40px;
	border: 4px solid #f3f3f3;
	border-top: 4px solid #007bff;
	border-radius: 50%;
	animation: spin 1s linear infinite;
}

@keyframes spin {
	0% {
		transform: rotate(0deg);
	}
	100% {
		transform: rotate(360deg);
	}
}

.error-boundary {
	text-align: center;
	padding: 2rem;
}

.error-boundary button {
	margin-top: 1rem;
	padding: 0.5rem 1rem;
	background-color: #007bff;
	color: white;
	border: none;
	border-radius: 0.25rem;
	cursor: pointer;
}
```

## 🧪 Testing Checklist

### Pre-deployment Testing

- [ ] **Token Generation**: Test generate token dengan session valid
- [ ] **URL Format**: Pastikan URL tidak memiliki hash fragment
- [ ] **Token Validation**: Test dengan token valid dan invalid
- [ ] **Error Handling**: Test dengan session expired
- [ ] **Pop-up Blocking**: Test jika pop-up diblokir

### Post-deployment Testing

- [ ] **Integration Test**: Test buka Flutter app dari Next.js
- [ ] **Auto Login**: Verifikasi user auto login di Flutter
- [ ] **URL Cleanup**: Cek URL parameters di-clear
- [ ] **Fallback**: Test jika token invalid

## 🔍 Debugging

### Console Logs yang Diharapkan

```javascript
// Saat buka kasir
"Generated Flutter URL: https://ourbit-cashier.web.app/?token=...";
"Opening Flutter app with URL: https://ourbit-cashier.web.app/?token=...";
```

### Error Handling

```javascript
// Jika session tidak ada
"Session error: ...";
"Error getting session";

// Jika token invalid
"Token tidak valid, silakan login ulang";

// Jika pop-up diblokir
"Pop-up diblokir. Silakan izinkan pop-up untuk situs ini.";
```

## 🚀 Deployment

### Build dan Deploy

```bash
# Build aplikasi
npm run build

# Deploy ke production
npm run start
# atau deploy ke Vercel/Netlify
```

### Environment Variables

Pastikan semua environment variables sudah diset dengan benar:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `NEXT_PUBLIC_FLUTTER_APP_URL`

## 📞 Support

### Common Issues

1. **Token tidak terkirim**: Cek session dan token format
2. **Pop-up diblokir**: Minta user izinkan pop-up
3. **URL dengan hash**: Pastikan tidak ada `#/login`
4. **Session expired**: Handle dengan graceful logout

### Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Next.js Documentation](https://nextjs.org/docs)
- [Flutter Web Integration](https://ourbit-cashier.web.app)
