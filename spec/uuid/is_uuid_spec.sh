#!/bin/sh

eval "$(shellspec - -c) exit 1"

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

  It 'Nil UUID（すべて0）に対して成功を返すこと'
    When call sx_uuid_is_uuid "00000000-0000-0000-0000-000000000000"
    The status should be success
  End

  It 'ハイフンのないUUID形式に対して失敗を返すこと'
    When call sx_uuid_is_uuid "550e8400e29b41d4a716446655440000"
    The status should be failure
  End

  It '桁数が不足しているUUIDに対して失敗を返すこと'
    When call sx_uuid_is_uuid "550e8400-e29b-41d4-a716"
    The status should be failure
  End

  It '複数の有効なUUIDを同時に検証できること'
    When call sx_uuid_is_uuid "550e8400-e29b-41d4-a716-446655440000" "00000000-0000-0000-0000-000000000000"
    The status should be success
  End

  It '有効なUUIDと無効なUUIDが混在した場合に失敗を返すこと'
    When call sx_uuid_is_uuid "550e8400-e29b-41d4-a716-446655440000" "invalid"
    The status should be failure
  End

  It '大文字のみのUUIDに対して成功を返すこと'
    When call sx_uuid_is_uuid "550E8400-E29B-41D4-A716-446655440000"
    The status should be success
  End
End
