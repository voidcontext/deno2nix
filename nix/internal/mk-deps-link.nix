{ lib
, linkFarm
, writeText
, deno2nix
, fetchurl
, deno
, ...
}:
let
  inherit (builtins) toJSON baseNameOf;
  inherit (lib) flatten mapAttrsToList importJSON;
  inherit (lib.strings) sanitizeDerivationName;
  inherit (deno2nix.internal) artifactPath;
in
lockfile: (
  linkFarm "deps" (flatten (
    mapAttrsToList
      (
        url: sha256:
        [
          {
            name = artifactPath url;
            path = fetchurl
              {
                inherit url sha256;
                name = sanitizeDerivationName (baseNameOf url);
                curlOptsList = [ "-A" "Deno/${deno.version}" ];
              };
          }
          {
            name = artifactPath url + ".metadata.json";
            path = writeText "metadata.json" (toJSON {
              inherit url;
              headers = { };
            });
          }
        ]
      )
      (importJSON lockfile).remote
  ))
)
