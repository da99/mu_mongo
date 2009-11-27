FeFe('Core') do

  describe :install do

    it %~
      Installs FeFe_The_French_Maid into your system.
    ~

    steps {
      sym_link {
        from __FILE__
        to   Gem.bindir, 'fefe'
      }
    }

  end

end

