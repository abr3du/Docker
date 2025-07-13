<?php
use App\Rules\HasStructuralObjectClass;

return [
    'default' => env('LDAP_CONNECTION', 'ldap'),
    'connections' => [
        'ldap' => [
            'hosts' => [env('LDAP_HOST', 'openldap')],
            'username' => env('LDAP_USERNAME', 'cn=admin,dc=example,dc=org'),
            'password' => env('LDAP_PASSWORD', 'adminpassword'),
            'port' => env('LDAP_PORT', 1389),
            'base_dn' => 'dc=example,dc=org',
            'timeout' => env('LDAP_TIMEOUT', 5),
            'use_ssl' => env('LDAP_SSL', false),
            'use_tls' => env('LDAP_TLS', false),
            'name' => env('LDAP_NAME', 'LDAP Server'),
        ],
    ],
    'logging' => env('LDAP_LOGGING', true),
    'cache' => [
        'enabled' => env('LDAP_CACHE', false),
        'driver' => env('CACHE_DRIVER', 'file'),
        'time' => env('LDAP_CACHE_TIME', 5*60),
    ],
    'validation' => [
        'objectclass' => [
            'objectclass.*' => [
                new HasStructuralObjectClass,
            ],
        ],
        'gidnumber' => [
            'gidnumber.*' => ['sometimes', 'max:1'],
            'gidnumber.*.*' => ['nullable', 'integer', 'max:65535'],
        ],
        'mail' => [
            'mail.*' => ['sometimes', 'min:1'],
            'mail.*.*' => ['nullable', 'email'],
        ],
        'userpassword' => [
            'userpassword.*' => ['sometimes', 'min:1'],
            'userpassword.*.*' => ['nullable', 'min:8'],
        ],
        'uidnumber' => [
            'uidnumber.*' => ['sometimes', 'max:1'],
            'uidnumber.*.*' => ['nullable', 'integer', 'max:65535'],
        ],
    ],
];