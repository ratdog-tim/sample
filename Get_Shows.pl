use strict;


sub get_year
{
	my ($show) = @_;
	if ($show =~ /^gd(\d\d)\-/) {
		my $yy = $1;
		return "19" . $yy;
	} elsif ($show =~ /^gd(\d\d\d\d)\-/) {
		my $yyyy = $1;
		return $yyyy;
	} elsif ($show =~ /^gd_nrps(\d\d)\-/) {
		my $yyyy = '19' . $1;
		return $yyyy;
	}
	
	die "error - unable to figure out year for show: $show\n";
}

sub get_show
{
	my ($show) = @_;

	my $year = get_year($show);

	my $show_dir = $year . '/' . $show;
	
	if ( -d $show_dir ) {
		warn "warning: show already exists, skipping: $show\n";
		return;
	}
	
	warn "making dir: $show_dir\n";
	`mkdir -p $show_dir`;

	# get the real url to the show from archive
	my $url;
	my $cmd = 'curl -verbose https://archive.org/download/__SHOW__/__SHOW___vbr.m3u 2>&1';
	$cmd =~ s/__SHOW__/${show}/g;
	my $xx = `$cmd`;
	if ($xx =~ /(https:\/\/[a-z0-9]+.us.archive.org\/[a-z0-9]+\/items\/)/ )
	{
		$url = $1;
		warn "Yay, got url to show: $url\n";
	} else {
	die "failed: \n $xx";
	}

	my $show_url = $url . $show . '/';
	my $cmd2 = "curl ${show_url}";	
	my $listing = `$cmd2`;
	
	my $listing_file = $show_dir . '/' . $show . "_archive_listing.txt";
	open(F , ">$listing_file") || die;
	print F $listing;
	close(F);

	warn "getting songs for show $show_dir\n";
	my @rows = split(/\n/,$listing);
	for my $line (@rows)
	{
		if ($line =~ /mp3"\>([A-Za-z0-9\-\.\_]+mp3)\<\/a\>/)
		{
			my $song = $1;
			
			print "WINNER: $song\n";
			
			my $cmd3 = "curl -o \"${show_dir}/${song}\" \"${show_url}${song}\"";
			
			print $cmd3,"\n";
			`$cmd3`;
		}
		if ($line =~ /txt"\>([A-Za-z0-9\-\.\_]+txt)\<\/a\>/)
		{
			my $song = $1;
			
			print "WINNER: $song\n";
			
			my $cmd3 = "curl -o \"${show_dir}/${song}\" \"${show_url}${song}\"";
			
			print $cmd3,"\n";
			`$cmd3`;
		}
	}
}


while (<>)
{
	if (-e "stop_get")
	{
		warn "Quitting for now, found stop_get\n";
		exit;
	}

	next if ($_ =~ /^#/);
	next if ($_ !~ /^g/);
	
	chomp($_);
	get_show($_);

}


__END__
