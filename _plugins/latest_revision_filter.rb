# Jekyll plugin to filter daily_pages to only latest revision
module Jekyll
  Hooks.register :site, :after_init do |site|
    # Get all daily_pages directories
    daily_pages_dir = Pathname.new(site.source).join("daily_pages")
    next unless daily_pages_dir.directory?
    
    # Find latest revision directory
    revision_dirs = daily_pages_dir.children.select { |d| d.directory? && d.basename.to_s.start_with?("content-") }
    next if revision_dirs.empty?
    
    latest_dir = revision_dirs.sort_by { |d| d.basename.to_s }.last
    latest_dir_name = latest_dir.basename.to_s
    
    # Exclude all other revision directories
    revision_dirs.each do |dir|
      next if dir == latest_dir
      dir_name = dir.basename.to_s
      exclude_path = "daily_pages/#{dir_name}"
      exclude_path_pattern = "daily_pages/#{dir_name}/**"
      site.exclude << exclude_path unless site.exclude.include?(exclude_path)
      site.exclude << exclude_path_pattern unless site.exclude.include?(exclude_path_pattern)
    end
    
    Jekyll.logger.info "Latest revision:", latest_dir_name
    excluded = (revision_dirs - [latest_dir]).map { |d| d.basename.to_s }
    Jekyll.logger.info "Excluded revisions:", excluded.join(", ") unless excluded.empty?
  end
end

