# Jekyll plugin to filter daily_pages to only latest revision
module Jekyll
  Hooks.register :site, :after_init do |site|
    begin
      # Get all daily_pages directories
      daily_pages_path = File.join(site.source, "daily_pages")
      unless File.directory?(daily_pages_path)
        Jekyll.logger.warn "Plugin:", "daily_pages directory not found at #{daily_pages_path}"
        next
      end
      
      # Find latest revision directory
      revision_dirs = Dir.glob(File.join(daily_pages_path, "content-*")).select { |d| File.directory?(d) }
      if revision_dirs.empty?
        Jekyll.logger.warn "Plugin:", "No revision directories found in daily_pages"
        next
      end
      
      latest_dir = revision_dirs.sort_by { |d| File.basename(d) }.last
      latest_dir_name = File.basename(latest_dir)
      
      # Exclude all other revision directories
      revision_dirs.each do |dir|
        next if dir == latest_dir
        dir_name = File.basename(dir)
        exclude_path = "daily_pages/#{dir_name}"
        exclude_path_pattern = "daily_pages/#{dir_name}/**"
        site.exclude << exclude_path unless site.exclude.include?(exclude_path)
        site.exclude << exclude_path_pattern unless site.exclude.include?(exclude_path_pattern)
      end
      
      Jekyll.logger.info "Plugin:", "Latest revision: #{latest_dir_name}"
      excluded = (revision_dirs - [latest_dir]).map { |d| File.basename(d) }
      Jekyll.logger.info "Plugin:", "Excluded revisions: #{excluded.join(', ')}" unless excluded.empty?
    rescue => e
      Jekyll.logger.error "Plugin Error:", e.message
      Jekyll.logger.error "Plugin Error:", e.backtrace.join("\n")
    end
  end
end

