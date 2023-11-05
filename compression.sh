# shellcheck shell=sh

_compress_util_help() {
	cat <<-EOF
	clist
		--normalize

	cunzip
	EOF
}

cls() {
	_compress_normalize=no
	for arg; do
		case "$arg" in
			--normalize) _compress_normalize=yes ;;
			--help) _compress_util_help; return ;;
		esac
	done

	case "$1" in
	*.zip)
		if [ "$_compress_normalize" = "no" ]; then
			unzip -l -- "$1"
		else
			unzip -l -- "$1" | awk '{ if(NR != 2 && NR !=3 && length($4) > 0) { print "./" $4 } }'
		fi
		;;
	*.tar)
		;;
	*)
		echo "Error: No match found" >&2
		;;
	esac
}

cunzip() {
	for arg; do
		case "$arg" in
		*.zip)
			folder="$(echo "$1" | rev | cut -d'.' -f2- | rev)"
			unzip -kd "$folder" "$1"
			[ -f "$folder" ] && return
			cd "$folder" || { _profile_util_die "mkt: Could not cd"; return; }
			[ "$(find . -maxdepth 1 | cut -c 3- | wc -l)" = 1 ] && {
				subfolder="$(ls)"
				mv "./$subfolder"/* "./$subfolder"/.* .
				rmdir "$subfolder"
				cd ..
			}
			;;
		*.tar) tar xf "$1" ;;
		*.tar.bz2) tar xjvf "$1" ;;
		*.tar.gz) tar xzvf "$1" ;;
		*.bz2) bunzip2 "$1" ;;
		*.rar) rar x "$1" ;;
		*.gz) gunzip "$1" ;;
		*.tbz2) tar xjvf "$1" ;;
		*.tgz) tar xzvf "$1" ;;
		*.Z) uncompress "$1" ;;
		*.7z) 7z x "$1" ;;
		*)
			echo "Error: No match found" >&2
			;;
		esac
	done
}

_czip_help() {
	cat <<-EOF
	czip

	Usage:
	    czip <directory> <algo>

	Example:
	    czip . <algo>
	EOF
}
# dtrx
czip() (
	dir="$1"
	algo="$2"

	[ -z "$algo" ] && {
		_profile_util_die "Algorithm must not be empty"
		exit
	}

	# name of zip from name of folder zipping
	zipFile="$(basename "$dir").$algo"

	# if dir is the same folder, we cd out
	# so there is a top level folder in the
	# compressed archive
	[ "$dir" = "." ] && {
		dir="$(basename "$(pwd)")"
		cd .. || { _profile_util_die "cd failed"; exit; }
		zipFile="$dir/$dir.$algo"
	}

	# ensure zip file doesn't already exixt
	[ -f "$zipFile" ] && {
		_profile_util_die "zipFile must not already exist"
		exit
	}

	echo "Creating '$zipFile' from '$dir' with '$algo'"
	case "$algo" in
	zip)
		zip -r "$zipFile" "$dir"
		;;
	tar)
		tar
		;;
	tar.bzip)
		tar --bzip2
		;;
	tar.xz)
		tar --xz
		;;
	tar.lzip)
		tar --lzip
		;;
	tar.lzma)
		tar --lzma
		;;
	tar.lzop)
		tar --lzop
		;;
	*)
		_profile_util_die "Compression algorithm not found"
		return
		;;
	esac
)
