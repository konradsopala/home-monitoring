import type { Metadata } from "next";
import React, { Suspense } from "react";
import "./globals.css";

export const metadata: Metadata = {
  title: "Home Monitoring",
  description: "Temperature and pressure monitoring dashboard",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className="min-h-screen bg-gray-950 antialiased">{children}</body>
    </html>
  );
}
