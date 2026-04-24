Describe 'sx_uuid_is_uuid'
  Include ./sx.sh
  It '有効なUUIDに対して成功を返すこと'
    When call sx_uuid_is_uuid "550e8400-e29b-41d4-a716-446655440000"
    The status should be success
  End

  It '無効なUUIDに対して失敗を返すこと'
    When call sx_uuid_is_uuid "invalid-uuid"
    The status should be failure
  End

  It '大文字小文字を区別しないこと'
    When call sx_uuid_is_uuid "550E8400-E29B-41D4-A716-446655440000"
    The status should be success
  End
End
