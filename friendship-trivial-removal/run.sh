#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" && source "${THIS_DIR}/../scripts/requirements.sh"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" && source "${THIS_DIR}/../scripts/psl.sh"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" && source "${THIS_DIR}/../scripts/tuffy.sh"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DATA_GEN_SCRIPT="${THIS_DIR}/scripts/generateFriendshipData.rb"
SPARSE_GEN_SCRIPT="${THIS_DIR}/scripts/generateSparseData.rb"

# Redefine for experiment specifics.
PSL_METHODS=('psl-admm-postgres')
PSL_METHODS_CLI_OPTIONS=('--postgres psl')
PSL_METHODS_JARS=("${PSL_JAR_PATH}")

# We need trace to get proper query stats.
# We also don't care about actually finding an answer, so tune down ADMM.
PSL_DEFAULT_OPTIONS='-D log4j.threshold=TRACE -D admmreasoner.maxiterations=1'
TUFFY_DEFAULT_EVAL_OPTIONS='-verbose 2 -maxFlips 1 -maxTries 3'

function run() {
   mkdir -p "${THIS_DIR}/data/friendship"
   mkdir -p "${THIS_DIR}/data/sparse"

   # local sizes="$(seq -w -s ' ' 0100 100 1000)"
   local sizes='0400'
   local falsePercents="$(seq -w -s ' ' 0 5 100)"

   for size in $sizes; do
      local baseDataDir="${THIS_DIR}/data/friendship/${size}"

      # Generate the base data.
      if [ ! -e "${THIS_DIR}/data/friendship/${size}" ]; then
         ruby $DATA_GEN_SCRIPT -p $size -l 10 -fh 0.85 -fl 0.15 -n friendship
         mv "${THIS_DIR}/data/friendship_${size}_0010" "${baseDataDir}"
      fi

      for falsePercent in $falsePercents; do
         local runId="${size}_${falsePercent}"
         local sparseDataDir="${THIS_DIR}/data/sparse/${runId}"

         # Generate the sparse data.
         if [ ! -e "${THIS_DIR}/data/sparse/${runId}" ]; then
            ruby $SPARSE_GEN_SCRIPT $baseDataDir $sparseDataDir $(echo "$falsePercent / 100" | bc -l)
         fi

         # PSL
         psl::runSuite \
            'friendship-trivial-removal' \
            "${THIS_DIR}" \
            "${runId}" \
            '' \
            "${runId}" \
            '' \
            false

         # Tuffy MaxWalkSat
         tuffy::runEval \
            "${THIS_DIR}/out/tuffy-maxwalksat/$runId" \
            "${THIS_DIR}/mln" \
            "${THIS_DIR}/scripts" \
            "${sparseDataDir}" \
            "${THIS_DIR}/mln/prog.mln" \
            ''
      done
   done
}

function main() {
   trap exit SIGINT

   requirements::check_requirements
   requirements::fetch_all_jars
   run
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
