package edu.sm.app.dto.oauth;

import java.util.Map;

public interface OAuth2UserInfo {
  String getProviderId();
  String getProvider();
  String getEmail();
  String getName();
}
