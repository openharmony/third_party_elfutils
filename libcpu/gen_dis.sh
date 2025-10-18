# Copyright (c) 2025 Huawei Device Co., Ltd.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/bash
set -e

DOGENDIS="$1"
OUTDIR="$2"
DEF_FILE="$3"
GENDIS_BIN="$4"

if [[ ! -f "${DEF_FILE}" ]]; then
    echo "Error, Not found ${DEF_FILE}"
fi

mkdir -p "${OUTDIR}"

ARCHS=("i386" "x86_64")

for arch in "${ARCHS[@]}"; do
    m4 -D${arch} -DDISASSEMBLER "${DEF_FILE}" > "${OUTDIR}/${arch}_defs"

    sed '1,/^%%/d;/^#/d;/^[[:space:]]*$$/d;
         s/[^:]*:\([^[:space:]]*\).*/MNE(\1)/;
         s/{[^}]*}//g;/INVALID/d' \
         "${OUTDIR}/${arch}_defs" | sort -u > "${OUTDIR}/${arch}.mnemonics"

    if [[ "${DOGENDIS}" == "true" ]]; then
        "${GENDIS_BIN}" "${OUTDIR}/${arch}_defs" > "${OUTDIR}/${arch}_dis.h"
    fi
done

