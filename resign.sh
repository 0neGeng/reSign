# !/bin/bash 
# Sample: 
#  sh resign.sh "com.xxoo.iphone"  "iPhone Developer: Jsz autotest (xxoo)"
# 
BUNDLE_ID="com.zxq.fzzj3"
CERTIFICATE="iPhone Distribution: shunguo Chen (4UA7TFA6YR)"
BundleVersion="2.11"

ORIGINAL_FILE="xycs-maoer.ipa"
MOBILEPROVISION="fzzj3ADHOC.mobileprovision"
PASSWD="maoer"


function unzip_IPA()
{
    ipa="$ORIGINAL_FILE"
    unzip -o "$ipa"
}

function create_EntitlementsPlist()
{
    /usr/libexec/PlistBuddy -x -c "print :Entitlements " /dev/stdin <<< $(security cms -D -i ${MOBILEPROVISION}) > entitlements.plist
    SN_CODE=$(/usr/libexec/PlistBuddy -c "Print :com.apple.developer.team-identifier" entitlements.plist)
    /usr/libexec/PlistBuddy -c "Set :application-identifier ${SN_CODE}.${BUNDLE_ID}" entitlements.plist
}

function set_BundleID()
{
     /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" Payload/*.app/Info.plist
}

function set_BundleVersion()
{
     /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BundleVersion" Payload/*.app/Info.plist
}

function del_OldCodeSign()
{
     rm -r Payload/*.app/_CodeSignature/
}

function copy_EmbeddedProvision()
{
     cp $MOBILEPROVISION Payload/*.app/embedded.mobileprovision
}
function reSignFrameworks()
{
    echo "Resigning with certificate: $CERTIFICATE" >&2
    find  −name"∗.app"−o−name"∗.appex"−o−name"∗.framework"−o−name"∗.dylib" > directories.txt

    while IFS='' read -r line || [[ -n "$line" ]]; do
    /usr/bin/codesign --continue -f -s "$CERTIFICATE" --no-strict "t_entitlements.plist"  "$line"
    done < directories.txt
}
function reSign()
{
    codesign -f -s "$CERTIFICATE" --entitlements entitlements.plist Payload/*.app/
}

function rezip_IPA()
{
    original_IPA=`basename "$ORIGINAL_FILE"`
    re_IPA=`echo ${original_IPA/.ipa/-resigned.ipa}`
    zip -qr "$re_IPA" Payload/
}

security unlock-keychain -p "$PASSWD" ~/Library/Keychains/login.keychain

#手动解压的话就注释了下面这句
#unzip_IPA
create_EntitlementsPlist
set_BundleID
if [ "$BundleVersion" !=  "" ]; then
set_BundleVersion
fi
del_OldCodeSign
copy_EmbeddedProvision
reSignFrameworks
reSign
rezip_IPA
