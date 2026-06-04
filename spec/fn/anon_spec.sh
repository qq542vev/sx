Describe 'sx_fn_anon'
	Include ./sx.sh

	It 'generates a unique function name and defines it'
		sx_fn_anon f_name 'echo "hello"'
		The value "$(eval "${f_name}")" should equal "hello"
	End

	It 'generates multiple functions'
		sx_fn_anon "f1:f2" 'echo "one"' 'echo "two"'
		The value "$(eval "${f1}")" should equal "one"
		The value "$(eval "${f2}")" should equal "two"
	End

	It 'returns the generated names in the binding'
		sx_fn_anon names 'echo 1' 'echo 2'
		The value "${names}" should match pattern 'sx_fn_anon_[0-9]* sx_fn_anon_[0-9]*'
	End

	It 'returns EX_USAGE (64) for invalid function bodies'
		When call sx_fn_anon f_name 'if'
		The status should equal 64
	End
End
