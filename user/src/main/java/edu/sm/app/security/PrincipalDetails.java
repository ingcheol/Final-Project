package edu.sm.app.security;

import edu.sm.app.dto.Patient;
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

  private Patient patient;
  private Map<String, Object> attributes;

  // 일반 로그인
  public PrincipalDetails(Patient patient) {
    this.patient = patient;
  }

  // OAuth2 로그인
  public PrincipalDetails(Patient patient, Map<String, Object> attributes) {
    this.patient = patient;
    this.attributes = attributes;
  }

  @Override
  public Map<String, Object> getAttributes() {
    return attributes;
  }

  @Override
  public Collection<? extends GrantedAuthority> getAuthorities() {
    return Collections.singleton(new SimpleGrantedAuthority(patient.getUserRole()));
  }

  @Override
  public String getPassword() {
    return patient.getPatientPwd();
  }

  @Override
  public String getUsername() {
    return patient.getPatientEmail();
  }

  @Override
  public boolean isAccountNonExpired() {
    return true;
  }

  @Override
  public boolean isAccountNonLocked() {
    return "active".equals(patient.getPatientAccountStatus());
  }

  @Override
  public boolean isCredentialsNonExpired() {
    return true;
  }

  @Override
  public boolean isEnabled() {
    return "active".equals(patient.getPatientAccountStatus());
  }

  @Override
  public String getName() {
    return String.valueOf(patient.getPatientName());
  }
}
