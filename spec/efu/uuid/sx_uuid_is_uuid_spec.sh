Describe 'sx_uuid_is_uuid -efu 環境検証'
  sxtest_load ./build/modules/sx_uuid_is_uuid.sh

  It '正常動作'

    When run efu_run sx_uuid_is_uuid "550e8400-e29b-41d4-a716-446655440000"
    The status should be success
  End
End
