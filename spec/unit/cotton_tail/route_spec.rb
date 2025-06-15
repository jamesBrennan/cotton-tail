# frozen_string_literal: true

module CottonTail
  describe Route do
    subject(:route) { described_class.new(pattern) }
    let(:opts) { { exchange_type: :topic } }

    describe '.match?' do
      describe 'exact matches' do
        let(:pattern) { 'a.b.c' }

        it 'behaves as expected' do
          expect(route.match?('a.b.c')).to be true
          expect(route.match?('a.b.c.d')).to be false
          expect(route.match?('a.b')).to be false
          expect(route.match?('b.c')).to be false
        end
      end

      describe 'wildcard matches' do
        describe 'segment wildcard at end' do
          let(:pattern) { 'a.b.*' }

          it 'behaves as expected' do
            expect(route.match?('a.b.c')).to be true
            expect(route.match?('a.b.z')).to be true
            expect(route.match?('a.b')).to be false
            expect(route.match?('a.b.c.d')).to be false
          end
        end

        describe 'segment wildcard at start' do
          let(:pattern) { '*.b.c' }

          it 'behaves as expected' do
            expect(route.match?('a.b.c')).to be true
            expect(route.match?('z.b.c')).to be true
            expect(route.match?('b.c')).to be false
            expect(route.match?('a.b.z')).to be false
          end
        end

        describe 'multiple segment wildcards' do
          let(:pattern) { '*.b.*.d' }

          it 'behaves as expected' do
            expect(route.match?('a.b.c.d')).to be true
            expect(route.match?('z.b.x.d')).to be true
            expect(route.match?('a.b.c')).to be false
            expect(route.match?('b.c.d')).to be false
          end
        end

        describe 'group wildcard at start' do
          let(:pattern) { '#.d' }

          it 'behaves as expected' do
            expect(route.match?('c.d')).to be true
            expect(route.match?('a.b.c.d')).to be true
            expect(route.match?('d')).to be true

            expect(route.match?('d.e')).to be false
            expect(route.match?('a.b.c')).to be false
          end
        end
      end
    end

    describe '.names' do
      subject { route.names }

      context 'given a pattern that is all single wildcards' do
        let(:pattern) { '*:domain.*:resource.*:action' }

        it { is_expected.to contain_exactly('domain', 'resource', 'action') }

        it 'matches as expected' do
          expect(route.match?('company.users.create')).to be true
          expect(route.match?('company.users.create.friend')).to be false
          expect(route.match?('company.users')).to be false
        end
      end

      context 'given a pattern with mixed wildcards' do
        let(:pattern) { '*:domain.#:resource_path.describe' }

        it { is_expected.to contain_exactly('domain', 'resource_path') }
      end

      context 'given a pattern this with some wildcards' do
        let(:pattern) { 'my-domain.*:resource.*:action' }

        it { is_expected.to contain_exactly('resource', 'action') }
      end
    end

    describe '.binding' do
      subject { route.binding }

      context 'given a pattern that is all single wildcards' do
        let(:pattern) { '*:domain.*:resource.*:action' }

        it { is_expected.to eql('*.*.*') }
      end

      context 'given a pattern that is mixed wildcards' do
        let(:pattern) { '*:domain.#:resource.*:action' }

        it { is_expected.to eql('*.#.*') }
      end

      context 'given mixed literals and wildcards' do
        let(:pattern) { 'company.*:resource.#' }

        it { is_expected.to eql('company.*.#') }
      end

      context 'given a simple string' do
        let(:pattern) { 'company.users.add' }

        it { is_expected.to eql pattern }
      end
    end

    describe '.extract_params' do
      subject(:route_params) { route.extract_params routing_key }

      context 'given a pattern that is all single wildcards' do
        let(:pattern) { '*:domain.*:resource.*:action' }

        context 'and a matching routing key' do
          let(:routing_key) { 'company.users.create' }

          it do
            expect(route_params).to(
              match('domain' => 'company', 'resource' => 'users', 'action' => 'create')
            )
          end
        end
      end

      context 'given a pattern that is mixed wildcards' do
        let(:pattern) { '*:domain.#:resource.*:action' }

        context 'and a matching routing key' do
          let(:routing_key) { 'company.users.create' }

          it do
            expect(route_params).to(
              match('domain' => 'company', 'resource' => 'users', 'action' => 'create')
            )
          end
        end

        context 'and a routing key that matches the extended wildcard' do
          let(:routing_key) { 'company.users.matched.list' }

          it do
            expect(route_params).to(
              match('domain' => 'company', 'resource' => 'users.matched', 'action' => 'list')
            )
          end
        end
      end

      context 'given a pattern without wildcards' do
        let(:pattern) { 'company.users.create' }
        let(:routing_key) { pattern }

        it { is_expected.to be_empty }
      end
    end
  end
end
