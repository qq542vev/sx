Describe 'sx_num_divceil_nat0 -efu 環境検証'
  Include ./spec/support/library.sh spec/efu/num/sx_num_divceil_nat0_spec.sh sx_num_divceil_nat0

  It '正常動作'

    When run efu_run sx_num_divceil_nat0 q 100 3
    The status should be success
  End
End
