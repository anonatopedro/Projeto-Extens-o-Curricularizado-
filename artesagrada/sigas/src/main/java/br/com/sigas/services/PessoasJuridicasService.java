package br.com.sigas.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.sigas.entities.PessoasJuridicas;
import br.com.sigas.repositories.PessoasJuridicasRepository;
import jakarta.persistence.EntityExistsException;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;

@Service
public class PessoasJuridicasService {

    @Autowired
    private PessoasJuridicasRepository pessoasJuridicasRepository;

    public PessoasJuridicas criarPessoaJuridica(PessoasJuridicas pessoaJuridica) {
        if (pessoasJuridicasRepository.buscaPorCnpj(pessoaJuridica.getCnpj()).isPresent()) {
            throw new EntityExistsException("CNPJ já cadastrado");
        }
        return pessoasJuridicasRepository.save(pessoaJuridica);
    }

    public PessoasJuridicas buscaPessoaJuridicaPorId(Long id) {
        return pessoasJuridicasRepository.buscaPessoaJuridicaPorId(id)
                .orElseThrow(() -> new EntityNotFoundException("Pessoa jurídica não encontrada"));
    }

    public List<PessoasJuridicas> buscarPorTrechoCnpj(String cnpj) {
        return pessoasJuridicasRepository.buscarPorTrechoCnpj(cnpj);
    }

    public List<PessoasJuridicas> buscarPessoaJuridicaPorNome(String nome) {
        return pessoasJuridicasRepository.buscarPessoaJuridicaPorNome(nome);
    }

    public List<PessoasJuridicas> buscarPorRazaoSocial(String razaoSocial) {
        return pessoasJuridicasRepository.buscarPorRazaoSocial(razaoSocial);
    }

    public List<PessoasJuridicas> buscarPessoaJuridicaPorEmail(String email) {
        return pessoasJuridicasRepository.buscarPorEmail(email);
    }

    @Transactional
    public void atualizarPessoaJuridica(Long id, PessoasJuridicas pessoaAtualizada) {
        // Validação: Certifique-se de que a pessoa existe antes de tentar atualizar
        pessoasJuridicasRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Pessoa Jurídica não encontrada"));

        // Chamando a procedure de atualização com todos os campos
        pessoasJuridicasRepository.atualizarPessoaJuridica(
                id.intValue(),
                pessoaAtualizada.getNome_pessoa(),
                pessoaAtualizada.getEmail_pessoa(),
                pessoaAtualizada.getEndereco_pessoa(),
                pessoaAtualizada.getTel1_pessoa(),
                pessoaAtualizada.getTel2_pessoa(),
                pessoaAtualizada.getCnpj(),
                pessoaAtualizada.getRazao_social());
    }

    @Transactional
    public void deletarPessoaJuridicaProcedure(Long id) {
        pessoasJuridicasRepository.deletarPessoaJuridica(id);
    }

}
