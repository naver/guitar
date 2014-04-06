#include "JSON.au3"
#include-once

; these are some examples of ways you can use the translator functionality built into the JSON.au3 library

func __JSONArrayConvert2($aIn)
	; convert a two-dimensional array into nested arrays
	local $l=ubound($aIn,1),$l2=ubound($aIn,2)
	local $a[$l],$a2[$l2]

	for $i=0 to $l-1
		for $i2=0 to $l2-1
			$a2[$i2]=$aIn[$i][$i2]
		next
		$a[$i]=$a2
	next

	return $a
endfunc

func __JSON_pack_translate($v,$type)
	; convert AutoIt-specific variable types to specially-formatted JSON objects
	return _JSONObject('_autoItType_',$type,'_autoItValue_',string($v))
endfunc

func fromDictionary($d)
	local $a=_JSONArray(),$i=0
	for $k in $d.keys()
		redim $a[$i+2]
		$a[$i]=$k
		$a[$i+1]=$d.item($k)
		$i+=2
	next
	return _JSONObjectFromArray($a)
endfunc

func JSON_pack($holder,$k,$v)
	select
	case isObj($v)
		if objName($v)=='IDictionary' then
			return fromDictionary($v)
		endif

	case isArray($v)
		if ubound($v,0)==2 and not _JSONIsObject($v) then
			return __JSONArrayConvert2($v)
		endif

	case isHWnd($v)
		; convert to object
		return __JSON_pack_translate($v,'hwnd')

	case isPtr($v)
		; convert to object
		return __JSON_pack_translate($v,'ptr')

	case isBinary($v)
		; convert to array of byte values
		return __JSON_pack_translate($v,'binary')

	endselect

	return $v
endfunc

func toDictionary(const byRef $a) ; to avoid unwanted mutation of booleans into numbers in the original array
	local $d=objCreate('Scripting.Dictionary')
	for $i=1 to ubound($a)-1
		local $key=$a[$i][0]
		if not _JSONIsNull($key) then
			$d.add($key,$a[$i][1])
		endif
	next
	return $d
endfunc

func JSON_unpack($holder,$k,$v)
	if _JSONIsObject($v) then
		local $d=toDictionary($v)
		if $d.count=2 and $d.exists('_autoItType_') and $d.exists('_autoItValue_') then
			switch $d.item('_autoItType_')
			case 'hwnd'
				return hwnd($d.item('_autoItValue_'))
			case 'binary'
				return binary($d.item('_autoItValue_'))
			case 'ptr'
				return ptr($d.item('_autoItValue_'))
			endswitch
		endif
		;~ return $d
	endif

	return $v
endfunc
