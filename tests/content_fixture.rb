module ContentFixture

  protected

  ##
  # Get fixture content
  #
  # @param [String] id
  # @param [String] __file    Test file (__FILE__)
  # @param [String] extension
  #
  def content(id, __file, extension: '.html')
    File.open(content_file(id, __file, extension: extension)).read
  end

  ##
  # Get path to content file
  #
  # @param [String] id
  # @param [String] __file    Test file (__FILE__)
  # @param [String] extension
  #
  def content_file(id, __file, extension: '.html')
    content_fixture_dir(__file) + '/' + File.basename(__file, '.rb') + '.' + id + extension
  end

  ##
  # Get path to fixture directory
  #
  # @param [String] __file
  #
  def content_fixture_dir(__file)
    File.dirname(__file) + '/_fixture'
  end
end
