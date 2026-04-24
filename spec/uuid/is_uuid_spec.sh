Describe 'sx_uuid_is_uuid'
  Include ./sx.sh
  It 'returns success for valid UUIDs'
    When call sx_uuid_is_uuid "550e8400-e29b-41d4-a716-446655440000"
    The status should be success
  End

  It 'returns failure for invalid UUIDs'
    When call sx_uuid_is_uuid "invalid-uuid"
    The status should be failure
  End

  It 'is case-insensitive'
    When call sx_uuid_is_uuid "550E8400-E29B-41D4-A716-446655440000"
    The status should be success
  End
End
