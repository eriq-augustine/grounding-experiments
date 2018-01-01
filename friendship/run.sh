#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" && source "${THIS_DIR}/../scripts/requirements.sh"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" && source "${THIS_DIR}/../scripts/psl.sh"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" && source "${THIS_DIR}/../scripts/tuffy.sh"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DATA_GEN_SCRIPT="${THIS_DIR}/scripts/generateFriendshipData.rb"

# Redefine for experiment specifics.
PSL_METHODS=('psl-admm-postgres')
PSL_METHODS_CLI_OPTIONS=('--postgres psl')
PSL_METHODS_JARS=("${PSL_JAR_PATH}")

# We need turn up logging to get proper timings.
PSL_DEFAULT_OPTIONS='-D log4j.threshold=TRACE'
TUFFY_DEFAULT_EVAL_OPTIONS='-verbose 2'

function run() {
   mkdir -p "${THIS_DIR}/data/friendship"

   local sizes="$(seq -w -s ' ' 0100 100 1000)"

   for size in $sizes; do
      local baseDataDir="${THIS_DIR}/data/friendship/${size}"

      # Generate the base data.
      if [ ! -e "${THIS_DIR}/data/friendship/${size}" ]; then
         ruby $DATA_GEN_SCRIPT -p $size -l 10 -fh 0.85 -fl 0.15 -n friendship
         mv "${THIS_DIR}/data/friendship_${size}_0010" "${baseDataDir}"
      fi

      # PSL
      psl::runSuite \
         'friendship' \
         "${THIS_DIR}" \
         "${size}" \
         '' \
         "${size}" \
         '' \
         false

      # Tuffy MaxWalkSat (Scope)
      tuffy::runEval \
         "${THIS_DIR}/out/tuffy-maxwalksat-scope/$size" \
         "${THIS_DIR}/mln" \
         "${THIS_DIR}/scripts" \
         "${baseDataDir}" \
         "${THIS_DIR}/mln/prog-scope.mln" \
         ''

      # Tuffy MaxWalkSat (No Scope)
      tuffy::runEval \
         "${THIS_DIR}/out/tuffy-maxwalksat-noscope/$size" \
         "${THIS_DIR}/mln" \
         "${THIS_DIR}/scripts" \
         "${baseDataDir}" \
         "${THIS_DIR}/mln/prog-noscope.mln" \
         ''
   done
}

function main() {
   trap exit SIGINT

   requirements::check_requirements
   requirements::fetch_all_jars
   run
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
