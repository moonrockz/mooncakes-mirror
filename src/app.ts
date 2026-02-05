/**
 * mooncakes Mirror Registry - TypeScript Glue Code
 *
 * This file provides TypeScript utilities and type definitions
 * for the moonbit/rabbit-tea application.
 */

// Type definitions for the registry data
export interface Stats {
  lastSync: string;
  totalPackages: number;
  totalOwners: number;
  yankedCount: number;
  source: string;
  mirrorUrl: string;
}

export interface PackageVersion {
  name: string;
  version: string;
  readme?: string;
  repository?: string;
  license?: string;
  keywords?: string[];
  checksum: string;
  created_at: string;
  yanked?: boolean;
  deprecated?: string;
}

export interface YankedPackage {
  name: string;
  version: string;
  reason: string;
}

export interface YankedData {
  yankedPackages: YankedPackage[];
  count: number;
  generatedAt: string;
}

// Utility functions that can be called from moonbit via FFI
export function formatDate(isoString: string): string {
  try {
    const date = new Date(isoString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  } catch {
    return isoString;
  }
}

export function formatNumber(num: number): string {
  return num.toLocaleString();
}

// Parse package index file (JSONL format)
export function parseIndexFile(content: string): PackageVersion[] {
  const lines = content.trim().split('\n');
  const packages: PackageVersion[] = [];

  for (const line of lines) {
    if (line.trim()) {
      try {
        packages.push(JSON.parse(line));
      } catch {
        console.warn('Failed to parse line:', line);
      }
    }
  }

  return packages;
}

// Group packages by owner
export function groupByOwner(packages: PackageVersion[]): Map<string, PackageVersion[]> {
  const grouped = new Map<string, PackageVersion[]>();

  for (const pkg of packages) {
    const [owner] = pkg.name.split('/');
    if (!grouped.has(owner)) {
      grouped.set(owner, []);
    }
    grouped.get(owner)!.push(pkg);
  }

  return grouped;
}

// Export for use in browser console during development
if (typeof window !== 'undefined') {
  (window as unknown as Record<string, unknown>).mooncakesUtils = {
    formatDate,
    formatNumber,
    parseIndexFile,
    groupByOwner,
  };
}
