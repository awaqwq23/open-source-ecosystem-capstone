# Vendored runtime

Source: flutter_qjs_next 1.5.1, downloaded from https://pub.dev/api/archives/flutter_qjs_next-1.5.1.tar.gz.
Archive SHA-256: `9e27b5acc54f2d19d8ea630a6bb0dec7ea75fb353ef4fe8cf9b07b343553acce`.
Upstream license and native QuickJS licenses are retained. Documentation, examples,
benchmarks and maintenance scripts are omitted from this runtime-only copy.

Local changes:

1. `lib/quickjs/quickjs_runtime2.dart`: `close()` frees the context/runtime without
   executing queued JavaScript jobs. A self-rescheduling Promise otherwise makes
   disposal drain forever, preventing native heap release. The host owns bounded
   job execution; disposal must never execute untrusted work.
2. Only Android native registration is enabled. External execution is
   explicitly rejected by the host on other platforms; builtin plugins still work.
   Upstream's Windows C sources failed MSVC/clang-cl verification (GNU attributes
   and POSIX headers), so they are not allowed to break the existing Windows app.
   Apple/Linux execution must be separately validated before enabling them.
3. Android NDK is pinned to `28.2.13676358`, the host Flutter 3.38.5 default,
   rather than implicitly downloading AGP's different default NDK.
4. `cxx/ffi.cpp`: compile the optional `mallopt(M_PURGE)` heap trim only for
   Android API 28+ targets. The library retains its API 21 minimum; lower targets
   return 0 for this unused optimization. Normal context/runtime freeing is
   unchanged. NDK 28 headers expose `mallopt` at API 26 and `M_PURGE` at API 28.

Upgrade only after the hostile-loop/disposal integration tests pass against the
replacement version. Do not silently return to upstream's unbounded job draining.
