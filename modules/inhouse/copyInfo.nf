process copyInfo {
  
  label 'copyInfo'
  module = ['interop/1.2.0-foss-2022a']

  input: 
  val(dummy)

  shell:
	template 'copyInfo.sh'
}