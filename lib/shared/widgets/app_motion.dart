import 'package:flutter/material.dart';

/// Shared motion system (Round 3, strengthened in Round 4) — ONE
/// animation approach for the whole app so Home, Listings, Detail,
/// Favorites, Profile, Auth and every other screen move the same way
/// instead of each screen inventing its own timing.
///
/// Round 4 diagnosis: the Round 3 entrances (14px travel, 300ms,
/// mount-only) were too subtle to perceive — especially with cached
/// data rendering instantly — so the travel is now ~22px, durations sit
/// in the 380–450ms band, the stagger is more pronounced, and list
/// cards use [ScrollReveal] so they animate as they actually enter the
/// viewport instead of only on first mount.
///
/// Rules:
/// - Animate ONLY opacity / transform (never layout) → no jank, 60fps.
/// - Entrances live in the 380–450ms band ([medium] / [slow]); small
///   UI feedback stays quick ([fast] / [press]).
/// - The system reduce-motion setting (`MediaQuery.disableAnimations`)
///   disables or simplifies every animation built on these helpers.
/// - No infinite / looping animations: everything here is finite and
///   settles, which also keeps widget tests `pumpAndSettle`-safe.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 450);

  /// Press feedback is quicker than entrances.
  static const Duration press = Duration(milliseconds: 120);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve reverseCurve = Curves.easeInCubic;

  /// Per-item stagger step used by lists/sections (capped by callers).
  /// Round 4: the step and cap were raised (55/330 → 70/560) so a
  /// staggered group reads as a deliberate cascade, not a flicker.
  static const int staggerStepMs = 70;
  static const int staggerCapMs = 560;

  /// Standard entrance travel (logical px, transform only).
  static const double entranceOffsetY = 22;

  /// Whether the user asked the OS to reduce motion.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// [duration] collapsed to zero when reduce-motion is on.
  static Duration effective(BuildContext context, Duration duration) =>
      reduceMotion(context) ? Duration.zero : duration;

  /// Stagger delay for the [index]-th item in a group.
  static Duration staggerDelay(int index) => Duration(
        milliseconds: (index * staggerStepMs).clamp(0, staggerCapMs),
      );
}

/// One-shot entrance animation: the child fades in while sliding up
/// ~22px (and optionally scaling up from [scaleFrom] for a subtle
/// "pop", used by category tiles and the profile avatar). Used for
/// above-the-fold blocks — Home hero/sections, Profile cards, the auth
/// card — that are visible as soon as they mount.
///
/// Implementation notes: a single [AnimationController] whose total
/// length is `delay + duration`; the visible motion runs through an
/// [Interval] so staggering needs no timers. When reduce-motion is on,
/// the child is shown immediately at full opacity/scale. The
/// controller is disposed with the state and the animation always
/// settles.
class FadeSlideIn extends StatefulWidget {
  final Widget child;

  /// Stagger delay before the entrance starts.
  final Duration delay;

  /// Entrance duration (defaults to [AppMotion.medium]).
  final Duration duration;

  /// Vertical travel in logical pixels (transform only).
  final double offsetY;

  /// Starting scale (1 = no scale). Values < 1 give a gentle pop-in.
  final double scaleFrom;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.medium,
    this.offsetY = AppMotion.entranceOffsetY,
    this.scaleFrom = 1,
  });

  /// Convenience constructor staggering by list [index].
  factory FadeSlideIn.staggered({
    Key? key,
    required int index,
    required Widget child,
    Duration duration = AppMotion.medium,
    double offsetY = AppMotion.entranceOffsetY,
    double scaleFrom = 1,
  }) {
    return FadeSlideIn(
      key: key,
      delay: AppMotion.staggerDelay(index),
      duration: duration,
      offsetY: offsetY,
      scaleFrom: scaleFrom,
      child: child,
    );
  }

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool _started = false;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);
    final begin = total.inMilliseconds == 0
        ? 0.0
        : widget.delay.inMilliseconds / total.inMilliseconds;
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, 1, curve: AppMotion.curve),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery may not be depended on during initState, so the
    // reduce-motion check + start happens here (runs once).
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final t = _animation.value;
        Widget result = Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - t)),
            child: child,
          ),
        );
        if (widget.scaleFrom != 1) {
          result = Transform.scale(
            scale: widget.scaleFrom + (1 - widget.scaleFrom) * t,
            child: result,
          );
        }
        return result;
      },
    );
  }
}

/// Scroll-triggered entrance (Round 4): like [FadeSlideIn], but the
/// animation starts when the child actually enters the viewport, not
/// when it is built — so cards far down a list (or appended by
/// pagination) animate as the user reaches them.
///
/// Performance design: ONE [AnimationController] per item, created
/// lazily by the item's own state; visibility is checked on the next
/// frame after build and on scroll notifications from the nearest
/// [Scrollable] (a cheap rect-overlap test, no per-item timers, no
/// visibility package). Once revealed, the scroll listener is removed
/// and the controller settles — revealed items cost nothing further.
/// The controller is disposed with the state. Under reduce-motion the
/// child renders fully visible immediately.
class ScrollReveal extends StatefulWidget {
  final Widget child;

  /// Stagger index within its group (delay = index × step, capped).
  final int index;

  /// Entrance duration (defaults to [AppMotion.medium]).
  final Duration duration;

  /// Vertical travel in logical pixels (transform only).
  final double offsetY;

  const ScrollReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = AppMotion.medium,
    this.offsetY = AppMotion.entranceOffsetY,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  ScrollPosition? _position;
  bool _revealed = false;
  bool _wired = false;

  @override
  void initState() {
    super.initState();
    final total = AppMotion.staggerDelay(widget.index) + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);
    final begin = total.inMilliseconds == 0
        ? 0.0
        : AppMotion.staggerDelay(widget.index).inMilliseconds /
            total.inMilliseconds;
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, 1, curve: AppMotion.curve),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _wired = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _revealed = true;
      _controller.value = 1;
      return;
    }
    // Listen to the nearest scrollable so below-fold items reveal as
    // they slide into view; also check once after the first frame for
    // items that are already visible.
    final scrollable = Scrollable.maybeOf(context);
    _position = scrollable?.position;
    _position?.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (_revealed || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final screen = Offset.zero & MediaQuery.sizeOf(context);
    // Reveal when the item intersects the viewport at all (2px
    // tolerance) — items merely peeking in should animate, and a
    // short item flush with the top edge must count as visible.
    final visible = rect.bottom > 2 && rect.top < screen.height - 2;
    if (visible) {
      _revealed = true;
      _position?.removeListener(_checkVisibility);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final t = _animation.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Skeleton → content crossfade (Round 4): an [AnimatedSwitcher]
/// preconfigured with the app motion tokens. Give successive states
/// different keys (e.g. `ValueKey('loading')` / `ValueKey('content')`)
/// and the old state fades/slides out as the new one fades in, instead
/// of the hard cut that made cached loads feel jumpy. Finite duration
/// — `pumpAndSettle`-safe; zero duration under reduce-motion.
class CrossfadeSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const CrossfadeSwitcher({
    super.key,
    required this.child,
    this.duration = AppMotion.medium,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.effective(context, duration),
      switchInCurve: AppMotion.curve,
      switchOutCurve: AppMotion.reverseCurve,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Press micro-interaction: scales the child down slightly while a
/// pointer is held on it, springing back on release. Pointer events are
/// observed with a [Listener] (never absorbed), so the child's own
/// InkWell / onTap keeps working untouched. This is the app's standard
/// press feedback alongside Material ripple.
class PressScale extends StatefulWidget {
  final Widget child;

  /// Scale while pressed (1 = no shrink).
  final double pressedScale;

  const PressScale({super.key, required this.child, this.pressedScale = 0.97});

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reduceMotion(context);
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: (_pressed && !reduce) ? widget.pressedScale : 1,
        duration: AppMotion.press,
        curve: AppMotion.curve,
        child: widget.child,
      ),
    );
  }
}
