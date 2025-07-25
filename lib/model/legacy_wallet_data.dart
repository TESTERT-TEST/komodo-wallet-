/// Models for Legacy Desktop Wallet data structures
///
/// These classes represent the data structures used in the legacy AtomicDEX desktop wallet
/// for configuration, address books, swap history, and maker orders.

/// Legacy address book entry
class LegacyAddressBookEntry {
  final String address;
  final String name;
  final String? description;
  final String coin;
  final DateTime? createdAt;

  const LegacyAddressBookEntry({
    required this.address,
    required this.name,
    this.description,
    required this.coin,
    this.createdAt,
  });

  factory LegacyAddressBookEntry.fromJson(Map<String, dynamic> json) {
    return LegacyAddressBookEntry(
      address: json['address'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coin: json['coin'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'name': name,
      if (description != null) 'description': description,
      'coin': coin,
      if (createdAt != null) 'created_at': createdAt!.millisecondsSinceEpoch,
    };
  }
}

/// Legacy swap history entry
class LegacySwapHistoryEntry {
  final String uuid;
  final String baseCoin;
  final String relCoin;
  final String baseAmount;
  final String relAmount;
  final String status;
  final DateTime timestamp;
  final bool isMaker;
  final String? txHash;
  final String? errorMessage;

  const LegacySwapHistoryEntry({
    required this.uuid,
    required this.baseCoin,
    required this.relCoin,
    required this.baseAmount,
    required this.relAmount,
    required this.status,
    required this.timestamp,
    required this.isMaker,
    this.txHash,
    this.errorMessage,
  });

  factory LegacySwapHistoryEntry.fromJson(Map<String, dynamic> json) {
    return LegacySwapHistoryEntry(
      uuid: json['uuid'] as String,
      baseCoin: json['base_coin'] as String,
      relCoin: json['rel_coin'] as String,
      baseAmount: json['base_amount'] as String,
      relAmount: json['rel_amount'] as String,
      status: json['status'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      isMaker: json['is_maker'] as bool? ?? false,
      txHash: json['tx_hash'] as String?,
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'base_coin': baseCoin,
      'rel_coin': relCoin,
      'base_amount': baseAmount,
      'rel_amount': relAmount,
      'status': status,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_maker': isMaker,
      if (txHash != null) 'tx_hash': txHash,
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }
}

/// Legacy maker order configuration
class LegacyMakerOrder {
  final String uuid;
  final String baseCoin;
  final String relCoin;
  final String price;
  final String volume;
  final String minVolume;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? strategy; // e.g., "keep_price", "spread_percent"
  final Map<String, dynamic>? metadata;

  const LegacyMakerOrder({
    required this.uuid,
    required this.baseCoin,
    required this.relCoin,
    required this.price,
    required this.volume,
    required this.minVolume,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.strategy,
    this.metadata,
  });

  factory LegacyMakerOrder.fromJson(Map<String, dynamic> json) {
    return LegacyMakerOrder(
      uuid: json['uuid'] as String,
      baseCoin: json['base_coin'] as String,
      relCoin: json['rel_coin'] as String,
      price: json['price'] as String,
      volume: json['volume'] as String,
      minVolume: json['min_volume'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int)
          : null,
      strategy: json['strategy'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'base_coin': baseCoin,
      'rel_coin': relCoin,
      'price': price,
      'volume': volume,
      'min_volume': minVolume,
      'is_active': isActive,
      'created_at': createdAt.millisecondsSinceEpoch,
      if (updatedAt != null) 'updated_at': updatedAt!.millisecondsSinceEpoch,
      if (strategy != null) 'strategy': strategy,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Legacy makerbot configuration
class LegacyMakerbotConfig {
  final String name;
  final bool isEnabled;
  final List<LegacyMakerOrder> orders;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime? lastRunAt;

  const LegacyMakerbotConfig({
    required this.name,
    required this.isEnabled,
    required this.orders,
    required this.settings,
    required this.createdAt,
    this.lastRunAt,
  });

  factory LegacyMakerbotConfig.fromJson(Map<String, dynamic> json) {
    return LegacyMakerbotConfig(
      name: json['name'] as String,
      isEnabled: json['is_enabled'] as bool? ?? false,
      orders: (json['orders'] as List<dynamic>? ?? [])
          .map((order) =>
              LegacyMakerOrder.fromJson(order as Map<String, dynamic>))
          .toList(),
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      lastRunAt: json['last_run_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_run_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'is_enabled': isEnabled,
      'orders': orders.map((order) => order.toJson()).toList(),
      'settings': settings,
      'created_at': createdAt.millisecondsSinceEpoch,
      if (lastRunAt != null) 'last_run_at': lastRunAt!.millisecondsSinceEpoch,
    };
  }
}

/// Complete legacy wallet data structure
class LegacyWalletData {
  final String walletName;
  final String mnemonic;
  final List<LegacyAddressBookEntry> addressBook;
  final List<LegacySwapHistoryEntry> swapHistory;
  final List<LegacyMakerOrder> makerOrders;
  final List<LegacyMakerbotConfig> makerbotConfigs;
  final Map<String, dynamic> settings;
  final DateTime exportedAt;

  const LegacyWalletData({
    required this.walletName,
    required this.mnemonic,
    required this.addressBook,
    required this.swapHistory,
    required this.makerOrders,
    required this.makerbotConfigs,
    required this.settings,
    required this.exportedAt,
  });

  factory LegacyWalletData.fromJson(Map<String, dynamic> json) {
    return LegacyWalletData(
      walletName: json['wallet_name'] as String,
      mnemonic: json['mnemonic'] as String,
      addressBook: (json['address_book'] as List<dynamic>? ?? [])
          .map((entry) =>
              LegacyAddressBookEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
      swapHistory: (json['swap_history'] as List<dynamic>? ?? [])
          .map((entry) =>
              LegacySwapHistoryEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
      makerOrders: (json['maker_orders'] as List<dynamic>? ?? [])
          .map((order) =>
              LegacyMakerOrder.fromJson(order as Map<String, dynamic>))
          .toList(),
      makerbotConfigs: (json['makerbot_configs'] as List<dynamic>? ?? [])
          .map((config) =>
              LegacyMakerbotConfig.fromJson(config as Map<String, dynamic>))
          .toList(),
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      exportedAt: json['exported_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['exported_at'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_name': walletName,
      'mnemonic': mnemonic,
      'address_book': addressBook.map((entry) => entry.toJson()).toList(),
      'swap_history': swapHistory.map((entry) => entry.toJson()).toList(),
      'maker_orders': makerOrders.map((order) => order.toJson()).toList(),
      'makerbot_configs':
          makerbotConfigs.map((config) => config.toJson()).toList(),
      'settings': settings,
      'exported_at': exportedAt.millisecondsSinceEpoch,
    };
  }

  /// Create a minimal legacy wallet data with just the mnemonic
  factory LegacyWalletData.seedOnly({
    required String walletName,
    required String mnemonic,
  }) {
    return LegacyWalletData(
      walletName: walletName,
      mnemonic: mnemonic,
      addressBook: [],
      swapHistory: [],
      makerOrders: [],
      makerbotConfigs: [],
      settings: {},
      exportedAt: DateTime.now(),
    );
  }
}
