#!/usr/bin/perl -w
#
# Script generates importprivkeys commands to be used during Noblecoin PoS transition.
#
use strict;
 
if (scalar @ARGV != 1) {
    print "Usage: $0 [location of noblecoind]\n\n";
    print qq(        Example: $0 "C:\\Noblecoin\\bin\\noblecoind"\n\n);
    die;
}
 
my $prog = $ARGV[0];
if (not -x $prog) {
    print "\nERROR: You need to provide path to noblecoind and it should be executable!\n\n";
    die;
}
 
my $unspent = `$prog listunspent`;
my @lines = split("\n", $unspent);
my @txs = ();
foreach (@lines) {
    if (/"txid"/) {
        s/.*: \"//;
        s/\",//;
        push @txs, $_;
#        print "txid: $_\n";
    }
}
 
my $trans_no = scalar @txs;
print "Found $trans_no transactions.\n";
 
my %addrs = ();
foreach my $tx (@txs) {
    my $get_tr = `$prog gettransaction $tx`;
    @lines = split("\n", $get_tr);
    foreach (@lines) {
        if (/"address"/) {
            $_ =~ m/.*\"address\" : \"(\w+)\"/;
            $addrs{$1} = 1;
        }
    }
}
my $addrs_no = keys %addrs;
print "Found $addrs_no addresses.\n";
 
print "----------------------\n";
print "This is list of commands you need to run in PoS wallet\n\n";
foreach (keys %addrs) {
    my $dump = `$prog dumpprivkey $_ `;
    chomp $dump;
    print "importprivkey $dump\n";
}
