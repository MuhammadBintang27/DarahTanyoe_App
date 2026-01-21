/// DEPRECATED: Use CampaignService instead
/// This file is kept for backwards compatibility only
/// All functionality has been migrated to CampaignService
/// 
/// Migration path:
/// - PermintaanDarahService.getAllPermintaan() -> CampaignService.getAllActiveCampaigns()
/// - PermintaanDarahService calls -> Use CampaignService instead

export 'campaign_service.dart';
