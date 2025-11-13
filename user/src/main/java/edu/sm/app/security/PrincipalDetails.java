package edu.sm.app.security;

import edu.sm.app.dto.User;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.Collection;
import java.util.Collections;
import java.util.Map;

@Getter
public class PrincipalDetails implements UserDetails, OAuth2User {

  private User user;
  private Map<String, Object> attributes;

  // 일반 로그인
  public PrincipalDetails(User user) {
    this.user = user;
  }

  // OAuth2 로그인
  public PrincipalDetails(User user, Map<String, Object> attributes) {
    this.user = user;
    this.attributes = attributes;
  }

  @Override
  public Map<String, Object> getAttributes() {
    return attributes;
  }

  @Override
  public Collection<? extends GrantedAuthority> getAuthorities() {
    return Collections.singleton(new SimpleGrantedAuthority(user.getUserRole()));
  }

  @Override
  public String getPassword() {
    return user.getUserPwd();
  }

  @Override
  public String getUsername() {
    return user.getUserEmail();
  }

  @Override
  public boolean isAccountNonExpired() {
    return true;
  }

  @Override
  public boolean isAccountNonLocked() {
    return "active".equals(user.getUserAccountStatus());
  }

  @Override
  public boolean isCredentialsNonExpired() {
    return true;
  }

  @Override
  public boolean isEnabled() {
    return "active".equals(user.getUserAccountStatus());
  }

  @Override
  public String getName() {
    return String.valueOf(user.getUserId());
  }
}
