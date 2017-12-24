#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" && source "${THIS_DIR}/../scripts/requirements.sh"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" && source "${THIS_DIR}/../scripts/psl.sh"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" && source "${THIS_DIR}/../scripts/tuffy.sh"
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DATA_GEN_SCRIPT="${THIS_DIR}/scripts/generateFriendshipData.rb"

# We just need PSL to load the data.
PSL_METHODS=('psl-admm-postgres')
PSL_METHODS_CLI_OPTIONS=('--postgres psl')
PSL_METHODS_JARS=("${PSL_JAR_PATH}")
PSL_DEFAULT_OPTIONS='-D log4j.threshold=TRACE -D admmreasoner.maxiterations=1'

QUERIES='similarity symmetry transitivity'
GROUNDING_METHODS='no-blocking cnf-implicit-blocking optimal-cover'
DATABASE='psl'

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

      # Run PSL to prep the database.
      psl::runSuite \
         'friendship-blocking' \
         "${THIS_DIR}" \
         "${size}" \
         '' \
         "${size}" \
         '' \
         false

      # Run the queries.
      local outDir="${THIS_DIR}/out/psl-admm-postgres/${size}"

      for query in $QUERIES; do
         for groundingMethod in $GROUNDING_METHODS; do
            local queryFile="${THIS_DIR}/sql/${query}-${groundingMethod}.sql"
            local outFile="${outDir}/${query}-${groundingMethod}.txt"

            echo -e "EXPLAIN (ANALYZE, BUFFERS, COSTS, SUMMARY, VERBOSE, FORMAT JSON)\n$(cat $queryFile)" | psql -qAt $DATABASE > "${outFile}"
         done
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
