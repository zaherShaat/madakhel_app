# Graph Report - E:\\Flutter\\madakhel\_app  (2026-05-07)

## Corpus Check
- Corpus is ~2,677 words - fits in a single context window. You may not need a graph.

## Summary
- 54 nodes · 20 edges · 35 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Structure Signals
- Entity graph basis: 20 non-file, non-concept node(s)
- Weakly connected components: 8
- Singleton components: 2
- Isolated nodes: 2
- Largest component: 4 node(s) (20% of the entity graph basis)
- Low-cohesion communities: 0
- Largest low-cohesion community: none on the entity graph basis

## Workspace Bridges
- None detected - no entity nodes currently connect multiple communities.

## God Nodes
1. `AppDelegate` - 4 edges
2. `GeneratedPluginRegistrant` - 4 edges
3. `handle\_new\_rx\_page\(\)` - 3 edges
4. `RunnerTests` - 3 edges
5. `MainActivity` - 2 edges
6. `SceneDelegate` - 2 edges
7. `\_\_lldb\_init\_module\(\)` - 1 edges
8. `.didInitializeImplicitFlutterEngine\(\)` - 1 edges
9. `.registerWith\(\)` - 1 edges
10. `.registerWithRegistry\(\)` - 1 edges

## Surprising Connections
- `GeneratedPluginRegistrant` --inherits--> `NSObject`  [EXTRACTED]
  E:/Flutter/madakhel\_app/ios/Runner/GeneratedPluginRegistrant.m → E:/Flutter/madakhel\_app/ios/Runner/GeneratedPluginRegistrant.h  _cross-file semantic connection_

## Semantic Anomalies
- **[HIGH] Bridge node** - handle\_new\_rx\_page\(\) bridges Ios Flutter Lldb Helper and Ios Flutter Lldb Helper — Lldb.
  _High betweenness centrality \(5.000\) across 2 communities makes this node a likely dependency chokepoint._
- **[MEDIUM] Cross-boundary edge** - GeneratedPluginRegistrant → NSObject crosses graph boundaries in an unexpected way.
  _cross-file semantic connection_

## Communities

### Community 0 - "Ios App Delegate"
Cohesion (entity basis within full-graph community): 0.5
Nodes (4): AppDelegate, .didInitializeImplicitFlutterEngine\(\), FlutterAppDelegate, FlutterImplicitEngineDelegate

### Community 1 - "Ios Generated Plugin Registrant"
Cohesion (entity basis within full-graph community): 0.5
Nodes (4): GeneratedPluginRegistrant, .registerWith\(\), .registerWithRegistry\(\), NSObject

### Community 2 - "Ios Runner Tests"
Cohesion (entity basis within full-graph community): 0.67
Nodes (3): RunnerTests, .testExample\(\), XCTestCase

### Community 3 - "Ios Flutter Lldb Helper"
Cohesion (entity basis within full-graph community): 0.67
Nodes (3): handle\_new\_rx\_page\(\), NOTE: NOTIFY\_DEBUGGER\_ABOUT\_RX\_PAGES will check contents of the, Intercept NOTIFY\_DEBUGGER\_ABOUT\_RX\_PAGES and touch the pages.

### Community 4 - "Android Main Activity"
Cohesion (entity basis within full-graph community): 1
Nodes (2): FlutterActivity, MainActivity

### Community 5 - "Ios Scene Delegate"
Cohesion (entity basis within full-graph community): 1
Nodes (2): FlutterSceneDelegate, SceneDelegate

### Community 6 - "Ios Flutter Lldb Helper — Lldb"
Cohesion (entity basis within full-graph community): 1
Nodes (1): \_\_lldb\_init\_module\(\)

### Community 7 - "Android Settings Gradle"
Cohesion (entity basis within full-graph community): 1
Nodes (1): require\(\)

### Community 8 - "Build Gradle Kts"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 9 - "Favicon Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 10 - "Ic Launcher Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 11 - "Icon 192 Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 12 - "Icon 512 Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 13 - "Icon App 1024x1024 1x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 14 - "Icon App 20x20 1x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 15 - "Icon App 20x20 2x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 16 - "Icon App 20x20 3x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 17 - "Icon App 29x29 1x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 18 - "Icon App 29x29 2x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 19 - "Icon App 29x29 3x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 20 - "Icon App 40x40 1x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 21 - "Icon App 40x40 2x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 22 - "Icon App 40x40 3x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 23 - "Icon App 60x60 2x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 24 - "Icon App 60x60 3x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 25 - "Icon App 76x76 1x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 26 - "Icon App 76x76 2x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 27 - "Icon App 83 5x83 5 2x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 28 - "Icon Maskable 192 Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 29 - "Icon Maskable 512 Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 30 - "Launch Image Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 31 - "Launch Image 2x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 32 - "Launch Image 3x Png"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 33 - "Lock SVG SVG"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

### Community 34 - "Runner Bridging Header H"
Cohesion (entity basis within full-graph community): n/a
Nodes (0): 

## Knowledge Gaps
- **16 weakly connected node(s):** `.registerWith\(\)`, `MainActivity`, `FlutterActivity`, `require\(\)`, `\_\_lldb\_init\_module\(\)` (+11 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Ios Flutter Lldb Helper — Lldb`** (2 nodes): `flutter\_lldb\_helper.py`, `\_\_lldb\_init\_module\(\)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Android Settings Gradle`** (2 nodes): `settings.gradle.kts`, `require\(\)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Build Gradle Kts`** (1 nodes): `build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Favicon Png`** (1 nodes): `favicon.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Ic Launcher Png`** (1 nodes): `ic\_launcher.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon 192 Png`** (1 nodes): `Icon-192.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon 512 Png`** (1 nodes): `Icon-512.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 1024x1024 1x Png`** (1 nodes): `Icon-App-1024x1024@1x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 20x20 1x Png`** (1 nodes): `Icon-App-20x20@1x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 20x20 2x Png`** (1 nodes): `Icon-App-20x20@2x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 20x20 3x Png`** (1 nodes): `Icon-App-20x20@3x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 29x29 1x Png`** (1 nodes): `Icon-App-29x29@1x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 29x29 2x Png`** (1 nodes): `Icon-App-29x29@2x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 29x29 3x Png`** (1 nodes): `Icon-App-29x29@3x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 40x40 1x Png`** (1 nodes): `Icon-App-40x40@1x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 40x40 2x Png`** (1 nodes): `Icon-App-40x40@2x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 40x40 3x Png`** (1 nodes): `Icon-App-40x40@3x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 60x60 2x Png`** (1 nodes): `Icon-App-60x60@2x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 60x60 3x Png`** (1 nodes): `Icon-App-60x60@3x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 76x76 1x Png`** (1 nodes): `Icon-App-76x76@1x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 76x76 2x Png`** (1 nodes): `Icon-App-76x76@2x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon App 83 5x83 5 2x Png`** (1 nodes): `Icon-App-83.5x83.5@2x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon Maskable 192 Png`** (1 nodes): `Icon-maskable-192.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Icon Maskable 512 Png`** (1 nodes): `Icon-maskable-512.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Launch Image Png`** (1 nodes): `LaunchImage.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Launch Image 2x Png`** (1 nodes): `LaunchImage@2x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Launch Image 3x Png`** (1 nodes): `LaunchImage@3x.png`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Lock SVG SVG`** (1 nodes): `lock.svg.svg`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Runner Bridging Header H`** (1 nodes): `Runner-Bridging-Header.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does \`handle\_new\_rx\_page\(\)\` connect \`Ios Flutter Lldb Helper\` to \`Ios Flutter Lldb Helper — Lldb\`?**
  _High betweenness centrality \(5.000\) - this node is a cross-community bridge._
- **What connects \`.registerWith\(\)\`, \`MainActivity\`, \`FlutterActivity\` to the rest of the system?**
  _16 weakly-connected nodes found - possible documentation gaps or missing edges._
