class AccountModel {
  final TenantInfo tenant;
  final OwnerInfo owner;
  final SubscriptionInfo subscription;
  final BillingInfo billing;
  final PaymentMethodInfo paymentMethod;
  final CancellationInfo cancellation;
  final String createdAt;

  const AccountModel({
    required this.tenant,
    required this.owner,
    required this.subscription,
    required this.billing,
    required this.paymentMethod,
    required this.cancellation,
    required this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      tenant: TenantInfo.fromJson(json['tenant']),
      owner: OwnerInfo.fromJson(json['owner']),
      subscription: SubscriptionInfo.fromJson(json['subscription']),
      billing: BillingInfo.fromJson(json['billing']),
      paymentMethod: PaymentMethodInfo.fromJson(json['payment_method']),
      cancellation: CancellationInfo.fromJson(json['cancellation']),
      createdAt: json['created_at'] ?? '',
    );
  }
}

// ─── Tenant ───────────────────────────────────────────────────────────────────
class TenantInfo {
  final String id;
  final String name;
  final String? slug;
  final String email;
  final String? razonSocial;
  final String? logo;

  const TenantInfo({
    required this.id,
    required this.name,
    this.slug,
    required this.email,
    this.razonSocial,
    this.logo,
  });

  factory TenantInfo.fromJson(Map<String, dynamic> json) => TenantInfo(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        email: json['email'],
        razonSocial: json['razon_social'],
        logo: json['logo'],
      );
}

// ─── Owner ────────────────────────────────────────────────────────────────────
class OwnerInfo {
  final String? name;
  final String? email;

  const OwnerInfo({this.name, this.email});

  factory OwnerInfo.fromJson(Map<String, dynamic> json) => OwnerInfo(
        name: json['name'],
        email: json['email'],
      );
}

// ─── Subscription ─────────────────────────────────────────────────────────────
class SubscriptionInfo {
  final String plan;
  final String status;
  final String period;
  final double basePrice;
  final String currency;
  final int includedBranches;
  final double extraBranchCost;
  final String? trialEndsAt;
  final String? nextBillingAt;
  final int daysLeft;
  final bool isTrialExpired;
  final int extraBranches;
  final double totalMonthly;

  const SubscriptionInfo({
    required this.plan,
    required this.status,
    required this.period,
    required this.basePrice,
    required this.currency,
    required this.includedBranches,
    required this.extraBranchCost,
    this.trialEndsAt,
    this.nextBillingAt,
    required this.daysLeft,
    required this.isTrialExpired,
    required this.extraBranches,
    required this.totalMonthly,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) => SubscriptionInfo(
        plan: json['plan'],
        status: json['status'],
        period: json['period'],
        basePrice: double.parse(json['base_price'].toString()),
        currency: json['currency'],
        includedBranches: json['included_branches'],
        extraBranchCost: double.parse(json['extra_branch_cost'].toString()),
        trialEndsAt: json['trial_ends_at'],
        nextBillingAt: json['next_billing_at'],
        daysLeft: json['days_left'],
        isTrialExpired: json['is_trial_expired'],
        extraBranches: json['extra_branches'],
        totalMonthly: double.parse(json['total_monthly'].toString()),
      );

  bool get isTrial => status == 'trial';
  bool get isActive => status == 'active';
  bool get isPastDue => status == 'past_due';
  bool get isCancelled => status == 'cancelled';

  String get planLabel => switch (plan) {
        'free_trial' => 'Free Trial',
        'basic' => 'Basic',
        'pro' => 'Pro',
        _ => plan,
      };

  String get periodLabel => period == 'monthly' ? 'mes' : 'año';
}

// ─── Billing ──────────────────────────────────────────────────────────────────
class BillingInfo {
  final String status;
  final bool isBlocked;
  final String nextCharge;

  const BillingInfo({
    required this.status,
    required this.isBlocked,
    required this.nextCharge,
  });

  factory BillingInfo.fromJson(Map<String, dynamic> json) => BillingInfo(
        status: json['status'],
        isBlocked: json['is_blocked'],
        nextCharge: json['next_charge'],
      );
}

// ─── Payment Method ───────────────────────────────────────────────────────────
class PaymentMethodInfo {
  final String? method;
  final String? clabe;
  final String? bank;
  final String? beneficiary;
  final String? reference;

  const PaymentMethodInfo({
    this.method,
    this.clabe,
    this.bank,
    this.beneficiary,
    this.reference,
  });

  factory PaymentMethodInfo.fromJson(Map<String, dynamic> json) => PaymentMethodInfo(
        method: json['method'],
        clabe: json['clabe'],
        bank: json['bank'],
        beneficiary: json['beneficiary'],
        reference: json['reference'],
      );

  bool get hasSpei => clabe != null;
}

// ─── Cancellation ─────────────────────────────────────────────────────────────
class CancellationInfo {
  final String? cancelledAt;
  final String? cancelReason;

  const CancellationInfo({this.cancelledAt, this.cancelReason});

  factory CancellationInfo.fromJson(Map<String, dynamic> json) => CancellationInfo(
        cancelledAt: json['cancelled_at'],
        cancelReason: json['cancel_reason'],
      );
}
