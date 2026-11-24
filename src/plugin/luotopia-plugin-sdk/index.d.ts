/** SPI v1. Types describe data; the host validates every boundary at runtime. */
export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };
export type Permission = 'storage.self' | 'network.https' | 'schoolTimetable.read';
export type ContributionSlot = 'navigation' | 'campusCard' | 'settingsRow';
export type PluginIcon = 'timer' | 'tune' | 'home' | 'list' | 'forum' | 'school' | 'settings' | 'book' | 'calendar' | 'star' | 'code' | 'cloud' | 'chart' | 'info';
export type PluginColor = 'sky' | 'blue' | 'green' | 'amber' | 'purple' | 'pink' | 'slate';
export interface Contribution {
  id: string;
  slot: ContributionSlot;
  /** 1..64 UTF-16 code units. */
  title: string;
  icon: PluginIcon;
  viewId: string;
  allowedViews: string[];
  size?: 'small' | 'wide' | null;
  color?: PluginColor | null;
  group?: 'extensions' | null;
}
export type ConfigField =
  // key: /^[a-zA-Z][a-zA-Z0-9_]{0,47}$/; labels/option values: 1..128 UTF-16 units.
  // choice options: 1..100; text maxLength counts UTF-16 units (1..4096).
  | { key: string; type: 'text'; label: string; default: string; maxLength: number }
  | { key: string; type: 'number'; label: string; default: number; min: number; max: number }
  | { key: string; type: 'boolean'; label: string; default: boolean }
  | { key: string; type: 'choice'; label: string; default: string; options: { value: string; label: string }[] };
export interface PluginManifest {
  schemaVersion: 1;
  id: string;
  /** 1..128 UTF-16 code units. */
  name: string;
  /** major.minor.patch without leading zeros, at most 32 characters. */
  version: string;
  apiVersion: 1;
  entry: 'main.js';
  /** 1..2000 UTF-16 code units; author/license each 1..128. */
  description: string;
  author: string;
  license: string;
  permissions: Permission[];
  /** At most 16 canonical exact DNS hosts; alphabetic TLD, 2..63 characters. */
  networkHosts: string[];
  /** 1..32 unique local view IDs. */
  views: string[];
  contributions: Contribution[];
  /** At most 32 unique fields. */
  config: ConfigField[];
}
export interface HostApi {
  storage: {
    get(key: string): Promise<Json>;
    set(key: string, value: Json): Promise<void>;
    remove(key: string): Promise<void>;
  };
  http: {
    request(request: { url: string; method: 'GET' | 'POST'; headers?: { [key: string]: string }; body?: string }):
      Promise<{ status: number; headers: { [key: string]: string }; body: string }>;
  };
  /** Requires schoolTimetable.read and WHU login; onAction only, local imported snapshot. */
  schoolTimetable: {
    listTimetables(): Promise<{ id: string; name: string; termLabel: string }[]>;
    getCourses(query: { timetableId: string; offset?: number; limit?: number }): Promise<{
      total: number; items: { id: string; title: string; location: string; instructor: string; startAt: string | null; endAt: string | null }[];
    }>;
  };
  openView(viewId: string): Promise<void>;
  log(level: 'debug' | 'info' | 'warn' | 'error', message: string): void;
}
export interface PluginContext {
  pluginId: string;
  contributionId: string;
  viewId: string;
  locale: 'zh' | 'en';
  theme: 'light' | 'dark';
  config: { [key: string]: Json };
  host: HostApi;
}
export interface RenderRequest { state: Json }
export interface ActionRequest { actionId: string; input: { [fieldId: string]: Json }; state: Json }
export interface PluginResult { state: Json; view: PluginView }
export interface LuotopiaPlugin {
  apiVersion: 1;
  activate?(context: PluginContext): void | Promise<void>;
  render(request: RenderRequest, context: PluginContext): PluginResult | Promise<PluginResult>;
  onAction(request: ActionRequest, context: PluginContext): PluginResult | Promise<PluginResult>;
  deactivate?(): void | Promise<void>;
}
export interface PluginView { title: string; nodes: ViewNode[] }
export type ViewNode =
  | { type: 'text'; id: string; text: string; tone?: 'normal' | 'muted' | 'error' }
  | { type: 'input'; id: string; label: string; value: string; maxLength: number; multiline?: boolean }
  | { type: 'number'; id: string; label: string; value: number; min: number; max: number }
  | { type: 'toggle'; id: string; label: string; value: boolean }
  | { type: 'select'; id: string; label: string; value: string; options: { value: string; label: string }[] }
  | { type: 'button'; id: string; label: string; actionId: string; style?: 'primary' | 'secondary' }
  | { type: 'list'; id: string; items: { id: string; title: string; subtitle?: string }[] };
/** Host Promise rejections are Error objects whose message is the error code. */
export type PluginError = Error;
declare global { var luotopiaPlugin: LuotopiaPlugin }
